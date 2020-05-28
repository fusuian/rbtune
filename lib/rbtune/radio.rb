# Radio仮想基底クラス
# Radiko, Radiru, Simul等で継承して使う
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
		outdir = '.'
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


	def record(filename, sec, wait: 0, quiet: false, dt: DateTime.now)
		uri = channel_to_uri
		raise 'not tuned yet.' unless uri
		puts "play: #{uri}"
		# $stderr.puts "play: #{sec}, #{filename}, #{quiet}, #{wait}"

		if wait > 0
			$stderr.puts "waiting #{wait} sec..."
			sleep wait
		end

		player = create_player uri

		res     = nil
		tmpfile = nil
		rtime   = 0
		s       = sec
		begin
			while s > 0 do
				rtime += Benchmark.realtime do
					dt = datetime dt
					tmpfile = make_tmpfile @channel, dt
					res = player.rec tmpfile, s, quiet
					# p ["*** res", res]
					convert tmpfile, make_recfile(filename, dt)
				end
				s -= rtime
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



