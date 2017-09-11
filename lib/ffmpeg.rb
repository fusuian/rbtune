# ffmpeg.rb
require "timeout"
require "open3"
require "player"
require "mplayer"

class FFMpeg < Player
	attr_accessor :output

	def initialize
		@mplayer = Mplayer.new('-')
	end


	def command
		'ffmpeg'
	end

	def options
		map{ |k,v| "-#{k} #{v}"}*' '
	end


	def to_s
		%Q(#{command} #{options} #{@output})
	end


	def play
		self['f'] = 'mpegts'
		@output = 'pipe:1'
		cmd = "#{to_s} | #{@mplayer}"
		$stderr.puts 'play: '+cmd
		`#{cmd}`
	end


	# secを指定しない場合、時間待ちをしない
	def rec(tmpfile, sec = nil, quiet = true)
		super
		if quiet
			# self['f'] = 'mpegts'
			@output = tmpfile
			cmd = to_s
		else
			self['f'] = 'mpegts'
			@output = 'pipe:1'
			cmd = "#{to_s} | tee #{tmpfile} | #{@mplayer}"
		end

		p "rec: #{cmd}"
		if sec 
			stdin, stdout, stderr, wait_thread = Open3.popen3(cmd)
			begin
				Timeout.timeout(sec) do
					wait_thread.join
			  end
			rescue Timeout::Error
				p "timeout"
				stdin.write 'q'
			end
		else
			`#{cmd}`
		end
	end

end