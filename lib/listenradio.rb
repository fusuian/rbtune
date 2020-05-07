#!/usr/bin/env ruby
=begin
リスラジまたはJCBAサイマルラジオを受信する
=end


require "radio"
require "player/ffmpeg"


class ListenRadio < Radio

	def self.channels
			listenradio = {
				"marine" => "http://mtist.as.smartstream.ne.jp/30061/livestream/playlist.m3u8"
			}
			jcba = {
				"urara" => "http://musicbird-hls.leanstream.co/musicbird/JCB020.stream/playlist.m3u8"
			}
			listenradio.merge jcba
	end

	def ext
		"mp4"
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