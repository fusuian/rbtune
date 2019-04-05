# mplayer.rb
require "timeout"
require "open3"
require "player"

class Mplayer < Player

	def initialize(url)
		@url=url
		self['cache'] = 256
		self['quiet'] = ''			# 画面表示をしない
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
		begin
			Timeout.timeout(sec) do
				wait_thread.join
		  end
		rescue Timeout::Error
			# p "timeout"
			stdin.write 'q'
		end
	end

end