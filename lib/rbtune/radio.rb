# Radio仮想基底クラス
# Radiko, Radiru等で継承して使う
#
# radio.login account, password (RadikoPremium 等、必要な場合のみ)
# radio.open
# radio.tune channel
# radio.play または radio.record
# radio.close

require "date"
require "benchmark"
require "net/http"
require "rexml/document"

class Radio
	attr_accessor :outdir
	attr_reader   :ext
	attr_reader   :area_id # for Radiko(Premium)
	attr_reader   :area_ja # for Radiko(Premium)
	attr_reader   :area_en # for Radiko(Premium)

	def Radio.inherited(subclass)
		@@bands ||= []
		@@bands << subclass
	end


	def initialize
		@outdir = '.'
		@ext = 'm4a'
	end


	def self.db
		@@db ||= Station::pstore_db
	end


	def self.stations
		@stations ||= self.db.transaction(true) { self.db[name] }
	end


	def self.channels
		@channels ||= self.stations.map {|st| [st.id, st.uri]}.to_h
	end


	def self.bands
		@@bands
	end


	def self.search(channel)
		radio_class, station = self.find(channel) || self.match(channel)
	end


	# Radioクラスのリストから、id と一致する放送局を探す
	# return: [Radioクラス, 放送局] or nil
	def self.find(id)
		Radio.bands.each do |tuner|
			if tuner.stations
				station = tuner.stations.find {|station| station.id == id}
				return [tuner, station] if station
			end
		end
		nil
	end


	# Radioクラスのリストから、name を含む放送局を探す
	# return: [Radioクラス, 放送局] or nil
	def self.match(name)
		matcher = /#{name}/i
		Radio.bands.each do |tuner|
			next unless tuner.stations
			found = tuner.stations.find { |station| station.name.match?(matcher) || station.ascii_name.match?(matcher) }
			return [tuner, found] if found
		end
		nil
	end


	def agent
		@agent ||= Mechanize.new
	end


	def create_player(uri)
		# rtmpdumpのコマンドラインを生成する(playから呼ばれる)
		FFMpeg.new( {
			i: uri,
			# acodec: 'copy', # acodecオプションはiオプションのあとに置かないとエラー
		} )
	end


	def login(account=nil, password=nil)
		# ラジオサービスにログイン
	end

	def open
	end

	def close
	end


	def tune(channel)
		@channel = channel
	end


	def channel_to_uri
		self.class::channels[@channel] || @channel
	end


	def record(filename, sec, quiet: false, dt: DateTime.now)
		begin
			uri = channel_to_uri
			raise 'not tuned yet.' unless uri

			puts "record: #{uri}"
			# $stderr.puts "play: #{sec}, #{filename}, #{quiet}"
			player      = create_player uri
			remain_sec  = sec
			rtime       = 0
			minimum_sec = 60   # 残り録音時間がこれ以下ならば、録音が中断してもやり直さない
			datetimes   = []
			begin
				rtime += Benchmark.realtime do
					dt = datetime dt
					datetimes << dt
					tmpfile = make_tmpfile @channel, dt
					player.rec tmpfile, remain_sec, quiet
				end
				remain_sec -= rtime
				dt = DateTime.now
			end while remain_sec >= minimum_sec

		rescue Interrupt, Errno::EPIPE
			# do nothing

		ensure
			# 最後にまとめて convert する
			datetimes.each do |dt|
				tmpfile = make_tmpfile @channel, dt
				recfile = make_recfile(filename, dt)
				convert tmpfile, recfile
			end
		end
	end


	def play
		uri = channel_to_uri
		raise 'not tuned yet.' unless uri
		puts "play: #{uri}"
		create_player(uri).play
	end


	def convert(tmpfile, recfile)
		FileUtils.mv tmpfile, recfile
	end


	def convert_ffmpeg(tmpfile, recfile)
		ffmpeg = FFMpeg.new
		ffmpeg['loglevel'] = 'quiet'
		ffmpeg['i'] = %Q("#{tmpfile}")
		# ffmpeg['b:a'] = '70k'
		stdout, stderr, status = ffmpeg.rec recfile, nil
		FileUtils.rm tmpfile if status.success?
	end


	def datetime(dt)
		dt.to_s[0..15].gsub(/:/, '=')
	end


	def make_tmpfile(channel, datetime)
		File.join outdir, "#{channel}.#{datetime}.#{$$}.#{ext}"
	end


	def out_ext
		@out_ext || ext
	end

	def make_recfile(title, datetime)
		File.join outdir, "#{title}.#{datetime}.#{out_ext}"
	end


	def fetch_stations
		body = agent.get stations_uri
		stations = parse_stations body
	end


	class HTTPBadRequestException < StandardError; end
	class HTTPForbiddenException < StandardError; end

end



