#!/usr/bin/env ruby

require "rbtune/radio"
require "player/mplayer"
require "rbtune/station"

class Simul < Radio

	def initialize
		super
		@ext     = 'asf'
		@out_ext = 'm4a'
	end


	def channel_to_uri
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


	def create_player(uri)
		mplayer = Mplayer.new uri
		mplayer.merge! 'benchmark' => '',	'vo' => 'null'
		mplayer
	end


	def convert(tmpfile, recfile)
		convert_ffmpeg(tmpfile, recfile)
	end


	def link_to_station_id(link)
		link =~ %r{(/asx/([\w-]+).asx|nkansai.tv/(\w+)/?\Z|(flower|redswave|fm-tanba|darazfm|AmamiFM|comiten|fm-shimabara|fm-kitaq))}
		id = ($2 || $3 || $4).sub(/fm[-_]/, 'fm').sub(/[-_]fm/, 'fm')
	end


	def stations_uri
		'http://www.simulradio.info'
	end


	def parse_stations(body)
		radioboxes = body / 'div.radiobox'
		radioboxes.map do |station|
			rows   = station / 'tr'
			cols   = rows[1] / 'td'
			ankers = station / 'a'

			player = ankers.select {|a|
				img = a.at 'img'
				img && img['alt'] == '放送を聴く'
			}

			title  = station.at('td > p > strong > a').text.strip
			links0 = player.map! {|e| e['href']}
			links  = links0.filter { |uri| uri =~ %r{\.asx\Z|nkansai.tv} }
			if links.empty?
				# $stderr.puts "#{title}: #{links0 * ', '}"
			else
				link = links[0]
				id   = link_to_station_id(link)
				if id
					Station.new(id, link, name: title, ascii_name: id)
				else
					$stderr.puts "!!! #{title}: #{link}"
				end
			end
		end.compact
	end


end
