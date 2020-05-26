# 文化放送 超A&G+ を受信する

require "rbtune/radio"
require "player/rtmpdump"
require "player/ffmpeg"
require "fileutils"

class Agqr < Radio

  def self.stations
    uri = "rtmp://fms-base1.mitene.ad.jp/agqr/aandg1"
    [Station.new('AGQR', uri, name: '超A&G+', ascii_name: 'aandg1')]
  end


  def ext; 'm4a'; end

  def create_player(channels)
    rtmpdump           = RtmpDump.new
    rtmpdump['rtmp']   = "rtmp://fms-base1.mitene.ad.jp/agqr/aandg1"
    rtmpdump
  end


  def convert(tmpfile, recfile)
    ffmpeg = FFMpeg.new
    ffmpeg['loglevel'] = 'quiet'
    ffmpeg['i'] = %Q("#{tmpfile}")
    ffmpeg['acodec'] = 'copy'
    stdout, stderr, status = ffmpeg.rec recfile
    FileUtils.rm tmpfile if status.success?
  end

end