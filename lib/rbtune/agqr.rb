# 文化放送 超A&G+ を受信する

require "rbtune/radio"

class Agqr < Radio
  def initialize
    @ext = 'm4a'
  end

  def fetch_stations
    uri = 'https://fms2.uniqueradio.jp/agqr10/aandg1.m3u8'
    [Station.new('AGQR', uri, name: '超A&G+', ascii_name: 'aandg1')]
  end

end