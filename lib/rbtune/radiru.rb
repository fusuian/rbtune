# radiru.rb
# coding: utf-8

require "rbtune/radio"
require "player/ffmpeg"
require "fileutils"

class Radiru < Radio

	def ext
		'm4a'
	end


	def create_player(uri)
		ffmpeg           = FFMpeg.new
		ffmpeg['i']      = uri # input stream
		ffmpeg['acodec'] = 'copy'  # acodecオプションはiオプションのあとに置かないとエラー
		ffmpeg
	end


	def make_tmpfile(channel, datetime)
		channel = 'radiru' unless Radiru::channels.has_key? channel
		File.join @outdir, "#{channel}.#{datetime}.#{$$}.#{ext}"
	end


  def stations_uri
    "https://www.nhk.or.jp/radio/config/config_web.xml"
  end


  def parse_stations(body)
    stations = body.search '//data'
    stationsjp = {
      'r1'=> "ラジオ第1",
      'r2'=> "ラジオ第2",
      'fm'=> "FM",
    }
    stations.map do |station|
      areajp = station.at('areajp').text
      area   = station.at('area').text
      r1, r2, fm = %w(r1 r2 fm).map do |v|
        hls = "#{v}hls"
        id  = "nhk#{v}-#{area}".upcase
        uri  = station.at(hls).text
        name = "NHK#{stationsjp[v]}（#{areajp}）"
        Station.new(id, uri, name: name, ascii_name: id)
      end
    end.flatten
  end

end
