# mplayer.rb
require "timeout"
require "open3"
require "player/player"

class Mplayer < Player

  WAIT_LIMIT = 3

	def initialize(url)
		@url = url
		self['quiet'] = ''      # 画面表示をしない
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


	def rec(file, sec, quiet: true, video: false)
		self['dumpstream'] = ''
		self['dumpfile']   = %Q("#{file}")
		if quiet
			self['nosound'] = ''	# 音声を再生しない
		end

		puts "rec (#{sec}s): #{to_s}"
		stdin, _stdout, _stderr, _wait_thread = Open3.popen3(to_s)
		dsec = -1
		psec = dsec
		wait = 0
		i = 0
		while dsec <= sec
			dsec = duration(file)
			if dsec == psec
				wait += 1
				break if wait > WAIT_LIMIT
			else
				wait = 0
				psec = dsec
			end
			p [i, dsec, psec, wait] if wait > 0
			i += 1
			sleep 1
		end
		stdin.write 'q'
	end

end