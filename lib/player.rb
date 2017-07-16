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




	private


end