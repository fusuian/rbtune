#radiko.rb
# coding: utf-8

require "rbtune/radiko"

class RadikoPremium < Radiko

	def self.set_authentication(kc, account)
		begin
			password = kc.query('radikoプレミアムのパスワードを入力してください', account)
			radio = RadikoPremium.new
			radio.login account, password
			kc.set account, password
			puts "Radikoプレミアムのアカウントが正しく登録されました"

		rescue Radio::HTTPForbiddenException
			$stderr.puts "アカウント情報が正しくありません"

		rescue RuntimeError
			$stderr.puts $!

		ensure
			radio && radio.close
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
		agent.post 'https://radiko.jp/ap/member/login/login', {
			mail: account, pass: password
		}

		begin
			params = []
			referer = nil
			@logged_in = true
			agent.get 'https://radiko.jp/ap/member/webapi/member/login/check', params, referer, headers
		rescue Mechanize::ResponseCodeError => ex
			raise HTTPForbiddenException if ex.message.include?('400 => Net::HTTPBadRequest')
		end
	end


	def close
		params = []
		referer = nil
		agent.get 'https://radiko.jp/ap/member/webapi/member/logout', params, referer, headers
		@logged_in = false
	end

	def stations_uri
		"http://radiko.jp/v3/station/region/full.xml"
	end



end
