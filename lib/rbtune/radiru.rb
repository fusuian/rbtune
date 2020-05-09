# radiru.rb
# coding: utf-8

require "rbtune/radio"
require "player/ffmpeg"
require "fileutils"

class Radiru < Radio
	def initialize
		super
	end

	def ext
		'm4a'
	end

	def self.channels
		{
			"nhkr1" => 'https://nhkradioakr1-i.akamaihd.net/hls/live/511633/1-r1/1-r1-01.m3u8',
			"nhkr2" => 'https://nhkradioakr2-i.akamaihd.net/hls/live/511929/1-r2/1-r2-01.m3u8',
			"nhkfm" => 'https://nhkradioakfm-i.akamaihd.net/hls/live/512290/1-fm/1-fm-01.m3u8',
		}
	end


	def create_player(channel)
		ffmpeg           = FFMpeg.new
		ffmpeg['i']      = channel # input stream
		ffmpeg['acodec'] = 'copy'  # acodecオプションはiオプションのあとに置かないとエラー
		ffmpeg
	end


	def play(opts={})
		raise 'not tuned yet.' unless @channel
		super opts
	end


	private


	def make_tmpfile(channel, datetime)
    channel = 'radiru' unless Radiru::channels.has_key? channel
		File.join @outdir, "#{channel}.#{datetime}.#{$$}.#{ext}"
	end

end
