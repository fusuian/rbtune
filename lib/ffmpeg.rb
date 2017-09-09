# ffmpeg.rb
require "player"
require "systemu"

class FFMpeg < Player

	def initialize
		@mplayer = Mplayer.new('-')
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
		self['f'] = 'mpegts'
		cmd = "#{to_s} pipe:1 | #{@mplayer}"
		$stderr.puts 'play: '+cmd
		`#{cmd}`
	end


	# secを指定しない場合、時間待ちをしない
	def rec(tmpfile, sec = nil, quiet = true)
		super
		if quiet
			cmd = "#{to_s} #{tmpfile}"
		else
			self['f'] = 'mpegts'
			cmd = "#{to_s} pipe:1 | tee #{tmpfile} | #{@qmplayer}"
		end
		# p "rec: #{cmd}: #{sec}"
		if sec 
			systemu cmd do |cid|
				sleep sec
				Process.kill :INT, cid+1
			end	
		else
			`#{cmd}`
		end
	end

end