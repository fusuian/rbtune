# ffmpeg.rb
require "timeout"
require "open3"
require "player"
require "mplayer"

class FFMpeg < Player
	attr_accessor :output

	def initialize
		self['loglevel'] = 'warning'
		self['n']        = '' # do not overwrite
		self['vn']       = '' # no video
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
		self['t'] = sec if sec 
		if quiet
			@output = tmpfile
			cmd = to_s
		else
			self['f'] = 'mpegts'
			@output = 'pipe:1'
			cmd = "#{to_s} | tee #{tmpfile} | #{@mplayer}"
		end

		p "rec: #{cmd}"
		`#{cmd}`
	end

end