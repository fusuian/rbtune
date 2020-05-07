require "radiko_premium"
require "player/ffmpeg"
require "date"
require "fileutils"

class DateTime
	def timefree
		strftime "%Y%m%d%H%M%S"
	end
end


class TimeFree < RadikoPremium
	def play(opts={})
		@channel = opts[:channel]
		sec = opts[:sec] || 1800.0
		starttime= opts[:from]
		endtime = starttime + sec/60/60/24
		filename = opts[:filename]

		from = starttime.timefree
		to   = endtime.timefree
		# pp [@channel, from, to]
		@stream_uri=%Q(https://radiko.jp/v2/api/ts/playlist.m3u8?l=15&station_id=#{@channel}&ft=#{from}&to=#{to})
		# radio_play datetime: starttime, filename: filename
		player = create_player self.class::channels[@channel]
		pp player
		dt = datetime starttime
		recfile = make_recfile filename, dt
		player.rec recfile
	end


	def create_player(channel)
		ffmpeg = FFMpeg.new
		ffmpeg['loglevel'] = 'info'
		ffmpeg['n']        = ''
		ffmpeg['headers']  = %Q("X-Radiko-AuthToken: #{@authtoken}")
		ffmpeg['i']        = %Q("#{@stream_uri}")
		ffmpeg['vn']       = ''
		ffmpeg['acodec']   = 'copy' # acodecオプションはiオプションのあとに置かないとエラー
		ffmpeg
	end
end
