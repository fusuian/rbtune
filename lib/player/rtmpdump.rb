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
		%x(#{to_s} | mplayer -)
	end


	def rec(file, sec, quiet: true, video: false)
		self['stop'] = sec

		if quiet
			self['flv'] = %Q("#{file}")
			puts "rec: #{to_s}"
			%x(#{to_s})
		else
			puts "rec: #{to_s}"
			%x(#{to_s} | tee "#{file}" | mplayer -)
		end
	end


end