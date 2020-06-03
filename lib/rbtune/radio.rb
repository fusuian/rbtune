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
	attr_accessor :area_id # for Radiko(Premium)
	attr_accessor :area_ja # for Radiko(Premium)
	attr_accessor :area_en # for Radiko(Premium)

	def Radio.inherited(subclass)
		@@bands ||= []
		@@bands << subclass
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


	def agent
		@agent ||= Mechanize.new
	end


	def fetch_stations
		body = agent.get stations_uri
		stations = parse_stations body
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

	def initialize
		self.outdir = '.'
	end

	def create_player(uri)
		# rtmpdumpのコマンドラインを生成する(playから呼ばれる)
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

			puts "play: #{uri}"
			# $stderr.puts "play: #{sec}, #{filename}, #{quiet}"
			player      = create_player uri
			remain_sec  = sec
			res         = nil
			tmpfile     = nil
			rtime       = 0
			minimum_sec = 60   # 残り録音時間がこれ以下ならば、録音が中断してもやり直さない
			while remain_sec > minimum_sec do
				rtime += Benchmark.realtime do
					dt = datetime dt
					tmpfile = make_tmpfile @channel, dt
					res = player.rec tmpfile, remain_sec, quiet
					# p ["*** res", res]
					convert tmpfile, make_recfile(filename, dt)
				end
				remain_sec -= rtime
				dt = DateTime.now
			end

		rescue Interrupt
			convert tmpfile, make_recfile(filename, dt)
		end
		res
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


	def datetime(dt)
		dt.to_s[0..15].gsub(/:/, '=')
	end


	def make_tmpfile(channel, datetime)
		File.join outdir, "#{channel}.#{datetime}.#{$$}.#{ext}"
	end


	def make_recfile(title, datetime)
		File.join outdir, "#{title}.#{datetime}.#{ext}"
	end

	class HTTPBadRequestException < StandardError; end
	class HTTPForbiddenException < StandardError; end

end



