# radiru.rb
# coding: utf-8

require "rbtune/radio"
require "player/ffmpeg"
require "fileutils"

class Radiru < Radio


	def stations_uri
		"https://www.nhk.or.jp/radio/config/config_web.xml"
	end


	def parse_stations(body)
		stations = body.search '//data'
		stationsjp = {
			'r1' => "ラジオ第1",
			'r2' => "ラジオ第2",
			'fm' => "FM",
		}
		stations = stations.map do |station|
			areajp = station.at('areajp').text
			area   = station.at('area').text
			# 地区ごとに第1, 第2, FM を登録する
			r1, r2, fm = %w(r1 r2 fm).map do |v|
				hls  = "#{v}hls"
				id   = "nhk#{v}-#{area}".upcase
				uri  = station.at(hls).text
				name = "NHK#{stationsjp[v]}-#{areajp}"
				Station.new(id, uri, name: name, ascii_name: id)
			end
		end
		stations.flatten!
		# id: NHKR1, NHKR2, NHKFM を東京局に割り当てる　
		stations.find_all { |station| station.id =~ /-TOKYO/}.reverse.map do |station|
			id = station.id.sub(/-TOKYO/, '')
			stations.unshift Station.new(id, station.uri, name: station.name, ascii_name: id)
		end
		stations
	end

end
