# ffmpeg.rb
require "timeout"
require "open3"
require "player/mplayer"

class FFMpeg < Player
	def initialize(hash={})
		self.merge! hash
		self['loglevel'] = 'warning'
		self['n']        = '' # do not overwrite
		@mplayer = Mplayer.new('-')
	end


	def command
		'ffmpeg'
	end

	def options
		map{ |k,v| "-#{k} #{v}"}*' '
	end


	def to_s
		%Q(#{command} #{options} #{@output})
	end


	def play
		self['f'] = 'asf'
		self['codec'] = 'copy'
		@output = '-'
		cmd = "#{to_s} | #{@mplayer}"
		$stderr.puts 'play: '+cmd
		`#{cmd}`
		raise $? unless $?.success?
	end


	def rec(file, sec, quiet = true)
		self['t'] = sec if sec
		self['codec'] = 'copy'
		@output = %Q("#{file}")
		cmd = to_s
		unless quiet
			cmd << %Q( -t #{sec} -f asf -codec copy - | #{@mplayer})
		end

		puts "rec: #{cmd}"
		stdout, stderr, status = Open3.capture3(cmd)
	end

end