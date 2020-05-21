#!/usr/bin/env ruby
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
require "rbtune/simul"
require "rbtune/listenradio"
require "rbtune/jcba"
require "mechanize"
require "pstore"
require "optparse"

fetch = false

opt = OptionParser.new
opt.version = Rbtune::VERSION
opt.banner += <<"EOS"
 RadioClass

 RadioClass : ListenRadio, Jcba, Simul

クラス別の放送局リストを表示する。

EOS
opt.on("-f", "--fetch", "ネットから放送局リストを取得する" ) {fetch = true}

opt.parse! ARGV
unless ARGV.size == 1
	puts opt.help
	exit 1
end

klass = Module.const_get(ARGV.shift)
radio = klass.new
unless radio.is_a? Radio
	puts "site #{klass} は正しくありません"
	exit 1
end


db = Station::pstore_db
name = radio.class.name
if fetch
	$stderr.puts "fetching #{name} stations..."
	agent = Mechanize.new
	body = agent.get radio.stations_uri
	$stderr.puts "parsing..."
	stations = radio.parse_stations body
	$stderr.puts "OK"
	db.transaction { db[name] = stations }
else
	stations = db.transaction(true) { db[name] }
end

stations.each { |station| puts station }
