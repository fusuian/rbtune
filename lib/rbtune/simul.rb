#!/usr/bin/env ruby

require "rbtune/radio"
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


	def channel
		ch = super
		if ch.end_with?('.asx')
			parse_asx ch
		else
			ch
		end
	end


	def parse_asx(uri)
		asx = Net::HTTP::get URI::parse(uri)
		asx.force_encoding "Shift_JIS"
		asx.encode! 'utf-8'
		asx.downcase!
		if asx.gsub!(%r(</ask>), '</asx>')
			$stderr.puts 'fix!! </ask> to <asx>'
		end
		doc = REXML::Document.new(asx)
		ref = doc.get_elements('//entry/ref')[0]
		ref.attribute('href').value
	end


	def create_player(channel)
		# ch = channels[channel]
		# raise "wrong channel: #{channel} " unless ch
		mplayer = Mplayer.new channel
		mplayer.merge! 'benchmark' => '',	'vo' => 'null', 'cache' => 192
		mplayer
	end


end
