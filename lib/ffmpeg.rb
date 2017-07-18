# ffmpeg.rb
require "player"

class FFMpeg < Player

	def initialize
	end


	def command
		'ffmpeg'
	end

	def options
		map{ |k,v| "-#{k} #{v}"}*' '
	end


	def to_s
		%Q(#{command} #{options} )
	end


	def play
		puts to_s
		`#{to_s}`
	end


	def rec(tmpfile, sec, quiet = true)
		super
		merge! 'acodec' => %Q(copy "#{tmpfile}")
		if quiet
			# merge! 'nosound' => ''
		end
		pp self
		puts to_s
		`#{to_s}`
	end

end