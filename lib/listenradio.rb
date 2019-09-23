#!/usr/bin/env ruby

require "radio"
require "ffmpeg"


class ListenRadio < Radio

	def self.channels
			{
				"marine" => "http://mtist.as.smartstream.ne.jp/30061/livestream/playlist.m3u8"
			}
	end	

	def create_player(channel)
		player = FFMpeg.new
		player['i']      = channel # input stream
		player['acodec'] = 'copy'  # acodecオプションはiオプションのあとに置かないとエラー
		player
	end

end


if $0 == 'lib/listenradio.rb'
	channel, min, filename = ARGV
	min ||= 30
	sec = min.to_f*60

	radio = ListenRadio.new
	begin
		radio.open
		radio.tune channel
		radio.play wait: 0, sec: sec, filename: filename, quiet: false
	ensure
		radio.close
	end
end