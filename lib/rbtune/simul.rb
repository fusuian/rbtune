#!/usr/bin/env ruby

require "rbtune/radio"
require "player/mplayer"
require "rbtune/station"

class Simul < Radio

	def self.channels
		@@db ||= Station::pstore_db
		@@stations ||= @@db.transaction(true) { @@db['simulradio'] }
		@@channels ||= @@stations.map {|st| [st.id, st.uri]}.to_h
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
		mplayer.merge! 'benchmark' => '',	'vo' => 'null'
		mplayer
	end


end
