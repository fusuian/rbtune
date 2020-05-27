require "rbtune/radiko_premium"
require "rbtune/station"
require "player/ffmpeg"
require "date"
require "fileutils"

class DateTime
	def timefree
		strftime "%Y%m%d%H%M%S"
	end
end


class TimeFree < RadikoPremium

	def record(filename, starttime, sec)
		endtime = starttime + sec/60/60/24

		from = starttime.timefree
		to   = endtime.timefree
		# pp [@channel, from, to]
		uri = channel_to_uri from, to
		player = create_player uri
		dt = datetime starttime
		recfile = make_recfile filename, dt
		stdout, stderr, status = player.rec recfile
		case stderr
		when /400 Bad Request/
			raise HTTPBadRequestException
		when /403 Forbidden/
			raise HTTPForbiddenException
		end
	end

	def channel_to_uri(from, to)
		%Q(https://radiko.jp/v2/api/ts/playlist.m3u8?l=15&station_id=#{@channel}&ft=#{from}&to=#{to})
	end


	def create_player(uri)
		ffmpeg = FFMpeg.new
		ffmpeg['loglevel'] = 'info'
		ffmpeg['headers']  = %Q("X-Radiko-AuthToken: #{authtoken}")
		ffmpeg['i']        = %Q("#{uri}")
		ffmpeg['acodec']   = 'copy' # acodecオプションはiオプションのあとに置かないとエラー
		ffmpeg
	end
end
