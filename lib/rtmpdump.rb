# rtmpdump.rb
require "player"


class RtmpDump < Player
	def initialize
		super
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


	def rec(tmpfile, sec, quiet = true)
		super
		self['stop'] = sec

		if quiet
			self['flv'] = tmpfile
			# pp to_s
			`#{to_s}`
		else
			# pp "#{to_s} | tee #{tmpfile} | mplayer -"
			`#{to_s} | tee #{tmpfile} | mplayer -`
		end
	end


end