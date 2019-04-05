#radiko.rb
# coding: utf-8

require "radiko"

class RadikoPremium < Radiko
	def self.channels
		{
		  'cbc' =>      "CBC",
		  'hbc' =>      "HBC",
		  'fmgunma' =>  "FMGUNMA",
		  'fmgumma' =>  "FMGUNMA",
		  'fmnagano' => "FMN",
		  'fmmie' =>    "FMMIE",
		  'tokai' =>    "TOKAIRADIO",
		  'fm802' =>    "802",
		  'rfc' => "RFC",
		  'rab' => "RAB",
		  'fmoita' =>   "FM_OITA",
		  'fmniigata' => "FMNIIGATA",
		  'mbs' => "MBS",
		  'obc' => "OBC",
		  'fmfuji' => "FM-FUJI",
		}
	end


	def headers
		{
			'pragma' => 'no-cache',
			'Cache-Control' => 'no-cache',
			'Expires' => 'Thu, 01 Jan 1970 00:00:00 GMT',
			'Accept-Language' => 'ja-jp',
			'Accept-Encoding' => 'gzip, deflate',
			'Accept' => 'application/json, text/javascript, */*; q=0.01',
			'X-Requested-With' => 'XMLHttpRequest'
		}
	end


	def login(account, password)
		res = @agent.post 'https://radiko.jp/ap/member/login/login', {
			mail: account, pass: password
		}

		params = []
		referer = nil
		@logged_in = true
		@agent.get 'https://radiko.jp/ap/member/webapi/member/login/check', params, referer, headers
	end


	def close
		params = []
		referer = nil
		@agent.get 'https://radiko.jp/ap/member/webapi/member/logout', params, referer, headers
		@logged_in = false
	end

end


if $0 == 'lib/radiko_premium.rb'
	channel, min, filename = ARGV
	min ||= 30
	sec = min.to_f*60
	account = "fusuian@gmail.com"
	password = "raradiko"

	radio = RadikoPremium.new
	begin
		radio.login account, password 
		radio.open
		radio.tune channel
		radio.play wait: 0, sec: sec, filename: filename, quiet: false
	ensure
		radio.close
	end
end
