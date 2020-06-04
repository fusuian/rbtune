# mplayer.rb
require "timeout"
require "open3"
require "player/player"

class Mplayer < Player

	def initialize(url)
		@url=url
		self['cache']     = 64
		self['cache-min'] = 16
		self['quiet']     = ''      # 画面表示をしない
	end


	def command
		'mplayer'
	end

	def options
		map{ |k,v| "-#{k} #{v}"}*' '
	end


	def to_s
		%Q(#{command} #{@url} #{options} )
	end


	def play
		puts to_s
		`#{to_s}`
	end


	def rec(tmpfile, sec, quiet = true)
		super
		self['dumpstream'] = ''
		self['dumpfile']   = tmpfile
		if quiet
			self['nosound'] = ''	# 音声を再生しない
		end

		stdin, stdout, stderr, wait_thread = Open3.popen3(to_s)
		dsec = -1
		start = Time.now
		while dsec <= sec
			dsec = duration(tmpfile)
			sleep 1
		end
		stdin.write 'q'
	end

end