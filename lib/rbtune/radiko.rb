#radiko.rb
# coding: utf-8

require "mechanize"
require "rbtune/radio"


class Radiko < Radio
	attr_reader :authtoken


	# get_auth2 の返り値により @area_id, @area_ja, @area_en が設定される
	def open
		@authtoken, partialkey = authenticate1 'https://radiko.jp/v2/api/auth1'
		@area_id, @area_ja, @area_en = authenticate2 'https://radiko.jp/v2/api/auth2', authtoken, partialkey
		puts "area: #{area_id} (#{area_ja}: #{area_en})"
	end


	def channel_to_uri
		uri = "http://radiko.jp/v2/station/stream_smh_multi/#{@channel}.xml"
		xml = agent.get uri
		xml.at('//url/playlist_create_url').text
	end


	def create_player(uri)
		FFMpeg.new( {
			headers: %Q("X-Radiko-Authtoken: #{authtoken}"),
			i: %Q("#{uri}"),
			# acodec: 'copy', # acodecオプションはiオプションのあとに置かないとエラー
		} )
	end


	def authenticate1(url)
		agent.request_headers = {
				'X-Radiko-App'         => 'pc_html5',
				'X-Radiko-App-Version' => '0.0.1',
				'X-Radiko-Device'      => 'pc',
				'X-Radiko-User'        => 'dummy_user',
			}
		res = agent.get url
		auth1 = res.response
		authtoken = auth1['x-radiko-authtoken']
		offset = auth1['x-radiko-keyoffset'].to_i
		length = auth1['x-radiko-keylength'].to_i
		partialkey = read_partialkey offset, length
		[authtoken, partialkey]
	end


	def read_partialkey(offset, length)
		key = "bcd151073c03b352e1ef2fd66c32209da9ca0afa"
		Base64.encode64(key[offset,length]).chomp
	end


	# return: area info
	def authenticate2(url, authtoken, partialkey)
		# pp [url, authtoken, partialkey]
		agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
		agent.request_headers = {
			'X-Radiko-Device'      => 'pc',
			'X-Radiko-User'        => 'dummy_user',
			'X-Radiko-Authtoken'   => authtoken,
			'X-Radiko-Partialkey'  => partialkey,
		}
		res = agent.get url
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


end
