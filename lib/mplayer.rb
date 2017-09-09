# mplayer.rb
require "player"

class Mplayer < Player

	def initialize(url)
		@url=url
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
		merge! 'dumpstream' => '', 'dumpfile' => tmpfile
		if quiet
			merge! 'nosound' => ''
		end
		pp self
		puts to_s

		systemu to_s do |cid|
			sleep sec
			Process.kill 2, cid
		end
	end

end