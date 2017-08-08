# simul.rb
require "radio"
require "mplayer"

class Simul < Radio

	def self.channels
		{
			"tachikawa" => "mmsh://hdv3.nkansai.tv/FmTachikawa?MSWMExt=.asf",
			"chofufm" => "mmsh://hdv3.nkansai.tv/chofu?MSWMExt=.asf",
			"comiten" => "mms://st1.shimabara.jp/comiten",
			"midfm" => "mmsh://203.141.56.46:80/mid-fm761?MSWMExt=.asf",
			"rainbowtown" => "mmsh://211.1.40.129:80/rainbowtown?MSWMExt=.asf",
			# "tsukuba" => "mmsh://211.1.40.21:80/tsukuba?MSWMExt=.asf"
			"tsukuba" => "mms://221.189.124.204/IRTsukuba"
		}
	end


	def ext
		'wma'
	end


	def create_player(channel)
		# ch = channels[channel]
		# raise "wrong channel: #{channel} " unless ch
		mplayer = Mplayer.new channel
		mplayer.merge! 'benchmark' => '',	'vo' => 'null', 'cache' => 192
		mplayer
	end


end


if $0 == 'lib/simul.rb'
	channel, min, filename
	min ||= 30
	sec = min.to_f*60

	radio = Simul.new
	begin
		radio.open
		radio.tune channel
		radio.play wait: 0, sec: sec, filename: filename, quiet: false
	ensure
		radio.close
	end

end