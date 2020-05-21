#!/usr/bin/env ruby
=begin
リスラジまたはJCBAサイマルラジオを受信する
=end


require "rbtune/radio"
require "player/ffmpeg"


class ListenRadio < Radio

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
