# Player 仮想クラス
# Mplayer等で継承して使う

class Player < Hash

	def command; end
	def play; end
	
	def rec(file, sec, quiet = true)
		raise "no stop sec" unless sec
	end


	def initialize
	end


	def options
		map{ |k,v| "--#{k} #{v}"}*' '
	end


	def to_s
		%Q(#{command} #{options} )
	end


	# 音声ファイル file の長さ(sec)を返す
	def duration(file)
		stdout, stderr, status = Open3.capture3("ffprobe #{file}")
		stderr =~ /Duration: (\d{2}):(\d{2}):(\d{2}.\d{2})/m
		hour, min, sec = [$1, $2, $3].map(&:to_f)
		hour*60*60 + min*60 + sec
	end

end