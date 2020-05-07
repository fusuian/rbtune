#!/usr/bin/env ruby

require "radio"
require "player/mplayer"

class Simul < Radio

	def self.channels
		{
			"tachikawa"   => "mmsh://hdv3.nkansai.tv/tachikawa",
			"chofufm"     => "mmsh://hdv3.nkansai.tv/chofu",
			"comiten"     => "mms://st1.shimabara.jp/comiten",
			"midfm"       => "mmsh://simuledge.shibapon.net/mid-fm761",
			"rainbowtown" => "mmsh://hdv3.nkansai.tv/rainbowtown",
			"tsukuba"     => "mmsh://hdv4.nkansai.tv/tsukuba",
			"ishinomaki"  => "mms://hdv2.nkansai.tv/ishinomaki",
			"fmuu"        => "mmsh://hdv4.nkansai.tv/fmuu", # FMうしくうれしく放送
			"takahagi"    => "mmsh://hdv4.nkansai.tv/takahagi", # たかはぎFM
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
