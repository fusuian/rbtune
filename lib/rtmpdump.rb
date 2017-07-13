# rtmpdump.rb
require "./lib/player"


class RtmpDump < Player
	def initialize
		super
		self.merge! 'live' => '', 'quiet' => ''
	end


	def command
		'rtmpdump'
	end


	def play
		puts "play: #{to_s} | mplayer -"
		`#{to_s} | mplayer -`
	end


	def rec(tmpfile, sec, quiet = true)
		super
		merge! 'stop' => sec

		if quiet
			merge! 'flv' => tmpfile
			pp to_s
			`#{to_s}`
		else
			pp "#{to_s} | tee #{tmpfile} | mplayer -"
			`#{to_s} | tee #{tmpfile} | mplayer -`
		end
	end


end