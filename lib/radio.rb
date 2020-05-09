# Radio仮想基底クラス
# Radiko, Radiru, Simul等で継承して使う
#
# radio.login account, password
# radio.open
# radio.tune channel
# radio.play
# radio.close

require 'swf_ruby'
require "date"
require "benchmark"
require "net/http"
require "rexml/document"

class Radio
	attr_accessor :outdir

	def Radio.inherited(subclass)
		@@bands ||= []
		@@bands << subclass
	end

	def self.bands
		@@bands
	end

	def initialize
		@outdir = '.'
	end

	def create_player
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


	def parse_asx(uri)
		asx = Net::HTTP::get URI::parse(uri)
		asx.force_encoding "Shift_JIS"
		asx.encode! 'utf-8'
		asx.downcase!

		doc = REXML::Document.new(asx)
		ref = doc.get_elements('//entry/ref')[0]
		ref.attribute('href').value
	end


	def channel
		case
		when @channel.end_with?('.asx')
			parse_asx @channel
		else
			self.class::channels[@channel] || @channel
		end
	end

	def play(opts={})
		raise 'not tuned yet.' unless @channel
		wait = opts[:wait] || 0
		sec = opts[:sec] || 1800
		filename = opts[:filename]
		quiet = opts[:quiet]
		dt = opts[:datetime] || DateTime.now

		# $stderr.puts "opts: #{opts}"
		# $stderr.puts "play: #{sec}, #{filename}, #{quiet}, #{wait}"

		if wait > 0
			$stderr.puts "waiting #{wait} sec..."
			sleep wait
		end

		ch = channel
		puts "play: #{ch}"
		player = create_player ch
		if filename
			rtime = 0
			s = sec
			res = nil
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
			res
		else
			player.play
		end
	end

	alias :radio_play :play



	def convert(tmpfile, recfile)
		FileUtils.mv tmpfile, recfile
	end


	private

	def get_file(url, file=nil)
		content = @agent.get_file(url)
		File.open(file, "wb") { |fout| fout.write content } if file
		content
	end

	def get(url)
		@agent.get(url)
	end


	def post(url, query={}, header={})
		res = @agent.post(url, query, header)
		res.body
	end


	def swfextract(swffile, character_id, out_file)
		swf = SwfRuby::SwfDumper.new
		swf.open(swffile)
		swf.tags.each_with_index do |tag, i|
			tag = swf.tags[i]
			if tag.character_id && tag.character_id == character_id
				offset = swf.tags_addresses[i]
				len = tag.length
				File.open(out_file, 'wb') { |out| out.print tag.data[6..-1] }
				break
			end
		end
	end


	def datetime(dt)
		dt.to_s[0..15].gsub(/:/, '=')
	end


	def make_tmpfile(channel, datetime)
		File.join @outdir, "#{channel}.#{datetime}.#{$$}.#{ext}"
	end


	def make_recfile(title, datetime)
		File.join @outdir, "#{title}.#{datetime}.#{ext}"
	end

	class HTTPBadRequestException < StandardError; end
	class HTTPForbiddenException < StandardError; end

end



