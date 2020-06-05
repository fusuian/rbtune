#radiko.rb
# coding: utf-8

require "mechanize"
require "rbtune/radio"
require "player/rtmpdump"
require 'swf_ruby'


class Radiko < Radio
	attr_reader :authtoken

	def initialize
		super
		@ext = 'flv'
	end

	def playerurl
		"http://radiko.jp/apps/js/flash/myplayer-release.swf"
	end


	def playerfile
		"player.swf"
	end


	def keyfile
		"authkey.png"
	end


	# get_auth2 の返り値により @area_id, @area_ja, @area_en が設定される
	def open
		unless File.exists? playerfile
			$stderr.puts 'fetching player...'
			fetch_file playerurl, playerfile
		end
		unless File.exists? keyfile
			swfextract playerfile, 12, keyfile
		end

		@authtoken, partialkey = authenticate1 'https://radiko.jp/v2/api/auth1_fms'
		@area_id, @area_ja, @area_en = authenticate2 'https://radiko.jp/v2/api/auth2_fms', authtoken, partialkey
		puts "area: #{area_id} (#{area_ja}: #{area_en})"
	end


	def channel_to_uri
		xml = agent.get "http://radiko.jp/v2/station/stream/#{@channel}.xml"
		xml.at('//url/item').text
	end


	def create_player(uri)
		rtmpdump           = RtmpDump.new
		rtmpdump['rtmp']   = uri
		rtmpdump['swfVfy'] = playerurl
		rtmpdump['conn']   = %Q(S:"" --conn S:""  --conn S:""  --conn S:#{authtoken})
		rtmpdump
	end


	def authenticate1(url)
		res = agent.post url, {}, {
				'pragma'               => 'no-cache',
				'X-Radiko-App'         => 'pc_ts',
				'X-Radiko-App-Version' => '4.0.0',
				'X-Radiko-User'        => 'test-stream',
				'X-Radiko-Device'      => 'pc',
			}
		s = res.body
		s.sub! /\r\n\r\n.*/m, ''
		arr = s.split(/\r\n/).map{|s| s.split('=')}.flatten
		auth1 = Hash[*arr]
		authtoken = auth1['X-Radiko-AuthToken'] || auth1['X-RADIKO-AUTHTOKEN']
		offset = auth1['X-Radiko-KeyOffset'].to_i
		length = auth1['X-Radiko-KeyLength'].to_i
		partialkey = read_partialkey keyfile, offset, length
		[authtoken, partialkey]
	end


	def read_partialkey(file, offset, length)
		key = File.open(file, "rb") { |io| io.read(offset + length) }
		Base64.encode64(key[offset,length]).chomp
	end


	# return: area info
	def authenticate2(url, authtoken, partialkey)
		# pp [url, authtoken, partialkey]
		agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
		res = agent.post url, {}, {
			'pragma'               => 'no-cache',
			'X-Radiko-App'         => 'pc_ts',
			'X-Radiko-App-Version' => '4.0.0',
			'X-Radiko-User'        => 'test-stream',
			'X-Radiko-Device'      => 'pc',
			'X-Radiko-Authtoken'   => authtoken,
			'X-Radiko-Partialkey'  => partialkey,
		}
		body = res.body
		body.force_encoding 'utf-8'
		body.split(',').map(&:strip)
	end


	def stations_uri
		"http://radiko.jp/v3/station/list/#{area_id}.xml"
	end


	def parse_stations(body)
		stations = body.search '//station'
		stations.map do |station|
			id         = station.at('id').text
			name       = station.at('name').text
			uri        = id
			ascii_name = station.at('ascii_name').text
			Station.new(id, uri, name: name, ascii_name: ascii_name)
		end
	end


	def fetch_file(url, file=nil)
		content = agent.get_file(url)
		File.open(file, "wb") { |fout| fout.write content } if file
		content
	end


	def swfextract(swffile, character_id, out_file)
		swf = SwfRuby::SwfDumper.new
		swf.open(swffile)
		swf.tags.each_with_index do |tag, i|
			tag = swf.tags[i]
			if tag.character_id && tag.character_id == character_id
				offset = swf.tags_addresses[i]
				len = tag.length
				File.open(out_file, 'wb') { |out| out.print tag.data[6..-1] }
				break
			end
		end
	end

end
