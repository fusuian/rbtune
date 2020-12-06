#!/usr/bin/env ruby
=begin
JCBAサイマルラジオを受信する
=end
require "rbtune/listenradio"


class Jcba < ListenRadio

	def stations_uri
		'https://www.jcbasimul.com'
	end


	def parse_stations(body)
		radioboxes = body / 'div.areaList ul li'
		stations = radioboxes.map do |station|
			h3      = station.at 'h3'
			rplayer = station.at 'div.rplayer'
			text    = station.at 'div.text'

			id   = rplayer['id']
			uri  = "http://musicbird-hls.leanstream.co/musicbird/#{id}.stream/playlist.m3u8"
			name = h3.text.sub(%r( / .*), '')
			desc = text.text
			# puts "(#{h3.text}) (#{rplayer['id']}) (#{text.text})"
			Station.new(id, uri, name: name, description: desc)
		end
	end

end
