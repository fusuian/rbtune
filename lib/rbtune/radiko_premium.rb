#radiko.rb
# coding: utf-8

require "rbtune/radiko"

class RadikoPremium < Radiko
	def self.channels
		{
			'cbc'       => "CBC",
			'hbc'       => "HBC",
			'fmgunma'   => "FMGUNMA",
			'fmgumma'   => "FMGUNMA",
			'fmnagano'  => "FMN",
			'fmmie'     => "FMMIE",
			'tokai'     => "TOKAIRADIO",
			'fm802'     => "802",
			'rfc'       => "RFC",
			'rab'       => "RAB",
			'fmoita'    => "FM_OITA",
			'fmniigata' => "FMNIIGATA",
			'mbs'       => "MBS",
			'obc'       => "OBC",
			'fmfuji'    => "FM-FUJI",
			'@fm'       => "FMAICHI",
			'k-mix'     => "K-MIX",
		}
	end


	def self.set_authentication(kc, account)
		begin
			kc.query('ラジコプレミアムのパスワードを入力してください', account)
		rescue RuntimeError => ex
			puts ex
		end
	end


	def headers
		{
			'pragma'           => 'no-cache',
			'Cache-Control'    => 'no-cache',
			'Expires'          => 'Thu, 01 Jan 1970 00:00:00 GMT',
			'Accept-Language'  => 'ja-jp',
			'Accept-Encoding'  => 'gzip, deflate',
			'Accept'           => 'application/json, text/javascript, */*; q=0.01',
			'X-Requested-With' => 'XMLHttpRequest'
		}
	end


	def login(account, password)
		res = @agent.post 'https://radiko.jp/ap/member/login/login', {
			mail: account, pass: password
		}

		begin
			params = []
			referer = nil
			@logged_in = true
			@agent.get 'https://radiko.jp/ap/member/webapi/member/login/check', params, referer, headers
		rescue Mechanize::ResponseCodeError => ex
			raise HTTPForbiddenException if ex.message.include?('400 => Net::HTTPBadRequest')
		end
	end


	def close
		params = []
		referer = nil
		@agent.get 'https://radiko.jp/ap/member/webapi/member/logout', params, referer, headers
		@logged_in = false
	end

end
