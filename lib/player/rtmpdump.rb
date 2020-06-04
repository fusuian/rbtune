# rtmpdump.rb
require "player/player"


class RtmpDump < Player
	def initialize
		self['live'] = ''
		self['quiet'] = ''
	end


	def command
		'rtmpdump'
	end


	def play
		# puts "play: #{to_s} | mplayer -"
		`#{to_s} | mplayer -`
	end


	def rec(file, sec, quiet = true)
		self['stop'] = sec

		if quiet
			self['flv'] = file
			`#{to_s}`
		else
			`#{to_s} | tee #{file} | mplayer -`
		end
	end


end