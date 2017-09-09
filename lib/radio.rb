# Radio仮想基底クラス
# Radiko, Radiru, Simul等で継承して使う
#
# radio.login account, password
# radio.open
# radio.tune channel
# radio.play
# radio.close

require "date"


class Radio
	attr_accessor :outdir

	def initialize
		@outdir = '.'
	end

	def create_player
		# rtmpdumpのコマンドラインを生成する(playから呼ばれる)
	end



	def channels
		# チャンネル名 => IDのhash
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

		player = create_player self.class::channels[@channel]
		if filename
			dt = datetime dt
			tmpfile = make_tmpfile @channel, dt
			player.rec tmpfile, sec, quiet
			convert tmpfile, make_recfile(filename, dt)
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


	def swfextract(swffile, outfile, option='')
		`swfextract #{option} #{swffile} -o #{outfile}`
		raise "failed extract" unless File.exists? outfile
	end


	def datetime(dt)
		dt.to_s[0..15].gsub(/:/, '=')
  end


	def make_tmpfile(channel, datetime)
		File.join @outdir, "#{channel}.#{datetime}.#{$$}.#{ext}"
		# File.join outdir, "#{$$}.tmp"
	end


	def make_recfile(title, datetime)
		File.join @outdir, "#{title}.#{datetime}.#{ext}"
	end

end



