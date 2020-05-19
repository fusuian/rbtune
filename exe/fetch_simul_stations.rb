=begin
サイマルラジオのサイト http://www.simulradio.info から放送局一覧を取得する。
listenradioのリンクやプレイヤーが開く局は除く。

局一覧は、Station::pstore_db の 'simalradio' に保存される

# 開けないリンク

# プレイヤーページが開く
RADIOワンダーストレージFMドラマシティ: http://live.776.fm/radio.html
さっぽろ村ラジオ: https://lve.jp/jcCb5GJOHwON/
FMあすも: http://fmasmo.fmplapla.com/player/
湘南ビーチFM: https://www.beachfm.co.jp/video/ https://www.beachfm.co.jp/radio/
CTY-FM: https://fmplapla.com/fmyokkaichi/
Pitch FM: https://fmplapla.com/pitchfm/
FM-N1: http://www.fmn1.jp/netradio.html https://www.fmn1.jp/netaudio.html
ハーバーステーション: http://www.web-services.jp/harbor779/

# 要 flash
FMひらかた: http://www.media-gather.jp/_mg_standard/deliverer2.php?p=IaxEXCgTuKI%3D

# 他、ListenRadio

=end

require "rbtune/station"
require "mechanize"
require "pstore"

@agent = Mechanize.new
uri = 'http://www.simulradio.info'

def link_to_station_id(link)
  link =~ %r{(/asx/([\w-]+).asx|nkansai.tv/(\w+)/?\Z|(flower|redswave|fm-tanba|darazfm|AmamiFM|comiten|fm-shimabara|fm-kitaq))}
  id = ($2 || $3 || $4).sub(/fm[-_]/, 'fm').sub(/[-_]fm/, 'fm')
end


def fetch_stations(uri)
  stations = []
  body = @agent.get uri
  radioboxes = body / 'div.radiobox'
  array = radioboxes.map do |station|
    rows = station / 'tr'
    cols = rows[1] / 'td'
    ankers = station / 'a'

    player = ankers.select {|a|
      img = a.at 'img'
      img && img['alt'] == '放送を聴く'
    }

    title = station.at('td > p > strong > a').text.strip
    links0 = player.map! {|e| e['href']}
    links = links0.filter { |uri| uri =~ %r{\.asx\Z|nkansai.tv} }
    if links.empty?
      # $stderr.puts "#{title}: #{links0 * ', '}"
    else
      link = links[0]
      id = link_to_station_id(link)
      if id
        stations << Station.new(id, link, name: title, ascii_name: id)
      else
        $stderr.puts "!!! #{title}: #{link}"
      end
    end
  end
  stations
end

stations = fetch_stations uri
db = Station::pstore_db
db.transaction do
  db['simulradio'] = stations
end
