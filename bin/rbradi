#!/usr/bin/env ruby
# coding: utf-8

require "rbradi"
include Rbradi

require "optparse"
require "pp"

channel = nil 
filename = nil 
min = 30 
# path = '/home/pi/radio'
outdir = '.'
wait = 0

account = "fusuian@gmail.com"
password =  "raradiko"

stations = {}

opt = OptionParser.new
opt.on("-c channel_name","--channel", stations.keys*'|'){|v| channel = v}
opt.on("-t [30]","--time", Float, "録音時間 (分）"){|v| min = v}
opt.on("-o ファイル名","--output","出力ファイル"){|v| filename = v}
opt.on("-w [0]", "--wait", Float, "録音開始までの待ち時間（秒）")
opt.parse! ARGV

radio_class = [Radiru, Radiko, RadikoPremium, Simul].find do |tuner|
  tuner::channels[channel]
end
raise "#{channel} not found." unless radio_class

sec = min*30

radio = radio_class.new
begin
	radio.login account, password 
	radio.open
	radio.tune channel
	radio.play wait: wait, sec: sec, filename: filename, quiet: false, outdir: outdir

ensure
	radio.close
end
