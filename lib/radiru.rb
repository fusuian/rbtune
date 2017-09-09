# radiru.rb
# coding: utf-8

require "radio"
require "ffmpeg"

class Radiru < Radio

	def ext
		'm4a'
	end

	def create_player(channel)
		ffmpeg = FFMpeg.new
		ffmpeg.merge! 'loglevel' => 'info', 'n' => ''
		ffmpeg.merge! 'i' => %Q("#{channel}")
		ffmpeg.merge! 'vn' => ''
	end


	def play(opts={})
		raise 'not tuned yet.' unless @channel
		p "radiru2: ", self.class, self.class::channels
		super opts
	end



	def self.channels
		{
			"nhkr1" => 'https://nhkradioakr1-i.akamaihd.net/hls/live/511633/1-r1/1-r1-01.m3u8',
			"nhkr2" => 'https://nhkradioakr2-i.akamaihd.net/hls/live/511929/1-r2/1-r2-01.m3u8',
			"nhkfm" => 'https://nhkradioakfm-i.akamaihd.net/hls/live/512290/1-fm/1-fm-01.m3u8',
		}
	end


end



if $0 == 'lib/radiru.rb'
	channel, min, filename = ARGV
	min ||= 30
	sec = min.to_f*60

	radio = Radiru.new
	begin
		radio.open
		radio.tune channel
		radio.play wait: 0, sec: sec, filename: filename, quiet: false
	ensure
		radio.close
	end
end
