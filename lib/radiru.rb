# radiru.rb
# coding: utf-8

require "./lib/radio"
require "./lib/rtmpdump"

class Radiru < Radio

	def ext
		'm4a'
	end

	def make_rtmpdump(channel)
		rtmp = "rtmpe://netradio-#{channel}-flash.nhk.jp"
		playpath = channel2flash[channel]
		playerurl= "http://www3.nhk.or.jp/netradio/files/swf/rtmpe.swf"
		app = "live"
		rtmpdump = RtmpDump.new
		rtmpdump.merge! 'rtmp' => rtmp, 'playpath' => playpath, 'swfVfy' => playerurl, 'app' => app
	end


	def channels
		{
			"nhk-r1" => 'r1',
			"nhk-r2" => 'r2',
			"nhk-fm" => 'fm',

			"nhk-r1[sendai]" => 'hkr1',
			"nhk-fm[sendai]" => 'hkfm',

			"nhk-r1[nagoya]" => 'ckr1',
			"nhk-fm[nagoya]" => 'ckfm',

			"nhk-r1[osaka]" => 'bkr1',
			"nhk-fm[osaka]" => 'bkfm',
		}
	end


	def channel2flash
		{
		  "fm" => 'NetRadio_FM_flash@63343',
		  "r1" => 'NetRadio_R1_flash@63346',
		  "r2" => 'NetRadio_R2_flash@63342',

		  "hkr1" => 'NetRadio_HKR1_flash@108442',
		  "hkfm" => 'NetRadio_HKFM_flash@108237',

		  "ckr1" => 'NetRadio_CKR1_flash@108234',
		  "ckfm" => 'NetRadio_CKFM_flash@108235',

		  "bkr1" => 'NetRadio_BKR1_flash@108232',
		  "bkfm" => 'NetRadio_BKFM_flash@108233',

		}
	end

end



if $0 == 'lib/radiru.rb'
	channel, min, filename, outdir = ARGV
	min ||= 30
	sec = min.to_f*60

	radio = Radiru.new
	begin
		radio.open
		radio.tune channel
		radio.play wait: 0, sec: sec, filename: filename, quiet: false, outdir: outdir
	ensure
		radio.close
	end
end
