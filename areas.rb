#!/usr/bin/env ruby	

require "mechanize"
require "pry"
require "rbradi"
require "pp"

def usage
<<EOS
area.rb JP8

JP1〜JP47の県コードからRadikoで聴ける放送局の名前とコードのリストを得る

EOS
end

if ARGV.empty?
	puts usage
	exit
end

area_id = ARGV[0]

radio=Radiko.new 

body=radio.agent.get "http://radiko.jp/v2/api/program/today", {'area_id'=>area_id}
stations = body.search '//station'
hash={}
stations.each do |st|
	hash[st.attr('id')] = st.at('name').text
end
pp hash
