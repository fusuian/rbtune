
class Radio
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
		wait = opts[:wait]
		sec = opts[:sec] || 1800
		filename = opts[:filename]
		quiet = opts[:quiet] || !filename
		@outdir = opts[:outdir] || '.'

		$stderr.puts "play: #{sec}, #{filename}, #{quiet}, #{wait}"

		if wait
			$stderr.puts "waiting #{wait} sec..."
			sleep wait 
		end

		player = create_player self.class::channels[@channel]
		pp player
		if filename
			dt = datetime
			tmpfile = make_tmpfile @channel, dt
			player.rec tmpfile, sec, quiet
			convert tmpfile, make_recfile(filename, dt)
		else
			player.play
		end
	end


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


	def datetime
		Time.now.strftime("%m%d-%y.%H%M")
  end


	def make_tmpfile(channel, datetime, outdir = @outdir)
		File.join outdir, "#{channel}.#{datetime}.#{$$}.tmp"
	end


	def make_recfile(title, datetime, outdir = @outdir)
		File.join outdir, "#{title}.#{datetime}.#{ext}"
	end

end



