# ffmpeg.rb
require "timeout"
require "open3"
require "player/mplayer"

class FFMpeg < Player
	attr_accessor :output

	def initialize
		self['loglevel'] = 'warning'
		self['n']        = '' # do not overwrite
		@mplayer = Mplayer.new('-')
	end


	def command
		'ffmpeg'
	end

	def options
		map{ |k,v| "-#{k} #{v}"}*' '
	end


	def to_s
		# novideoオプション -vn は、この位置でないと機能しない
		%Q(#{command} #{options} -vn #{@output})
	end


	def play
		self['f'] = 'mpegts'
		@output = 'pipe:1'
		cmd = "#{to_s} | #{@mplayer}"
		$stderr.puts 'play: '+cmd
		`#{cmd}`
		raise $? unless $?.success
	end


	# secを指定しない場合、時間待ちをしない
	def rec(tmpfile, sec = nil, quiet = true)
		self['t'] = sec if sec
		if quiet
			@output = tmpfile
			cmd = to_s
		else
			self['f'] = 'mpegts'
			@output = 'pipe:1'
			cmd = "#{to_s} | tee #{tmpfile} | #{@mplayer}"
		end

		puts "rec: #{cmd}"
		stdout, stderr, status = Open3.capture3(cmd)
	end

end