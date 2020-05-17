#radiko.rb
# coding: utf-8

require "mechanize"
require "rbtune/radio"
require "player/rtmpdump"
# require "pry"

class Radiko < Radio

	def initialize
		super
		@playerurl  = "http://radiko.jp/apps/js/flash/myplayer-release.swf"
		@playerfile = "player.swf"
		@keyfile    = "authkey.png"
		@agent = Mechanize.new
	end

	attr_reader :agent

	def self.channels
		{
			'tbs'            => "TBS",
			'bunka'          => "QRR",
			'nippon_hoso'    => "LFR",
			'radio_nippon'   => "JORF",
			'ibaraki_hoso'   => "IBS",

			'nikkei1'        => "RN1",
			'nikkei2'        => "RN2",

			'interfm'        => "INT",
			'fmtokyo'        => "FMT",
			'tokyofm'        => "FMT",
			'tokyo_fm'       => "FMT",
			'jwave'          => "FMJ",
			'bayfm'          => "BAYFM78",
			'nack5'          => "NACK5",
			'yokohama'       => "YFM",

			'housou-daigaku' => "HOUSOU-DAIGAKU",
			'hoso-daigaku'   => "HOUSOU-DAIGAKU",
		}
	end


	def open
		unless File.exists? @playerfile
			$stderr.puts 'fetching player...'
			get_file @playerurl, @playerfile
		end
		unless File.exists? @keyfile
			swfextract @playerfile, 12, @keyfile
		end

		# $stderr.puts 'fetching auth1...'
		auth1 = get_auth1 'https://radiko.jp/v2/api/auth1_fms'
		# pp auth1
		@authtoken = auth1['X-Radiko-AuthToken'] || auth1['X-RADIKO-AUTHTOKEN']
		offset = auth1['X-Radiko-KeyOffset'].to_i
		length = auth1['X-Radiko-KeyLength'].to_i
		# pp [@authtoken, offset, length]
		# binding.pry unless @authtoken
		@partialkey = get_partialkey @keyfile, offset, length

		# $stderr.puts 'fetching auth2...'
		# pp [@authtoken, @partialkey]
		@areaid = get_auth2 'https://radiko.jp/v2/api/auth2_fms', @authtoken, @partialkey
	end

  def tune(ch)
    super
    # $stderr.puts "fetching #{channel}.xml..."
    xml = get "http://radiko.jp/v2/station/stream/#{channel}.xml"
    @stream_uri = xml.at('//url/item').text
  end



	def ext
		'm4a'
	end



	def create_player(channel)
		rtmpdump           = RtmpDump.new
		rtmpdump['rtmp']   = @stream_uri
		rtmpdump['swfVfy'] = @playerurl
		rtmpdump['conn']   = %Q(S:"" --conn S:""  --conn S:""  --conn S:#{@authtoken})
		rtmpdump
	end


	def get_auth1(url)
		s = post url, {}, {
				'pragma'               => 'no-cache',
				'X-Radiko-App'         => 'pc_ts',
				'X-Radiko-App-Version' => '4.0.0',
				'X-Radiko-User'        => 'test-stream',
				'X-Radiko-Device'      => 'pc',
			}
		s.sub! /\r\n\r\n.*/m, ''
		arr = s.split(/\r\n/).map{|s| s.split('=')}.flatten
		return Hash[*arr]
	end


	def get_partialkey(file, offset, length)
		key = File.open(file, "rb") { |io| io.read(offset + length) }
		Base64.encode64(key[offset,length]).chomp
	end

	def get_auth2(url, authtoken, partialkey)
		# pp [url, authtoken, partialkey]
		@agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
		res = post url, {}, {
			'pragma'               => 'no-cache',
			'X-Radiko-App'         => 'pc_ts',
			'X-Radiko-App-Version' => '4.0.0',
			'X-Radiko-User'        => 'test-stream',
			'X-Radiko-Device'      => 'pc',
			'X-Radiko-Authtoken'   => authtoken,
			'X-Radiko-Partialkey'  => partialkey,
		}
		# pp ">>>\n#{res}\n<<<"
		res.sub! /\r\n/m, ''
		areaid = res.split(',')[0]
	end

	def make_tmpfile(channel, datetime)
		File.join @outdir, "#{channel}.#{datetime}.#{$$}.aac"
	end


end
