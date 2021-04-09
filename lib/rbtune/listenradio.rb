#!/usr/bin/env ruby
=begin
リスラジまたはJCBAサイマルラジオを受信する
=end


require "rbtune/radio"
require "json"


class ListenRadio < Radio

	def stations_uri
		'http://listenradio.jp/service/channel.aspx'
	end


	def parse_stations(body)
		json = JSON[body.body, symbolize_names: true]
		stations = json[:Channel].map do |station|
			name = station[:ChannelName]
			id   = station[:ChannelId]
			desc = station[:ChannelDetail]
			uri  = station[:ChannelHls]
			# puts "'#{name}' <#{uri}> #{desc}"
			Station.new(id, uri, name: name, description: desc)
		end
	end

end
