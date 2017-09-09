# ffmpeg.rb
require "player"
require "systemu"

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
		$stderr.puts 'play: '+to_s
		`#{to_s} -f mp3 pipe:1 | mplayer -`
	end


	def rec(tmpfile, sec = nil, quiet = true)
		super
		cmd = "#{to_s} #{tmpfile}"
		$stderr.puts 'rec:' + cmd
		if sec 
			systemu cmd do |cid|
				sleep sec
				Process.kill :INT, cid
			end	
		else
			`#{cmd}`
		end
	end

end