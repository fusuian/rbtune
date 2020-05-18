#!/usr/bin/env ruby

require "rbtune/radiko"
require "selenium-webdriver"
require "mechanize"
require "pstore"


class RadikoPrefecture
  def initialize
    @agent = Mechanize.new
  end


  def fetch_stations(uri)
    body = @agent.get uri
    stations = body.search '//station'
    array = stations.map do |station|
      id = station.at('id').text
      name = station.at('name').text
      text = station.at('ascii_name').text
      ascii_name = normalize(text)
      p [text, name, ascii_name]
      [ascii_name, id]
     end
    Hash[array]
  end


  def fetch_all_stations
    fetch_stations "http://radiko.jp/v3/station/region/full.xml"
  end

  def normalize(str)
    {
      "JOLF NIPPON HOSO"=> "nipponhoso",
      "RF RADIO NIPPON" => "radionippon",
      "FM802" => "fm802",
      "E-RADIO"=>"eradio",
      "ATFM" => "fmaichi",
      "bayfm78" => "bayfm",
    }[str] ||
    str.downcase.gsub(/[ _]/, '-')
    .gsub(/[']/, '')
    .sub(/housou-/, '')
    .sub(/jo\w\w-(\w+)-hoso/, "\\1")
    .sub(/-?\d\d?\.?\d\Z/, '')
    .sub(/\Aradio-?/, '').sub(/-?radio\Z/, '')
    .gsub(/-/, '')
  end

  def fetch_stations_by_pref(pref)
    fetch_stations "http://radiko.jp/v3/station/list/#{pref}.xml"
  end


  # ラジコの配信エリアページから県名を得る
  def fetch_my_region
    uri = 'http://radiko.jp/#!/distribution_area'
    driver = Selenium::WebDriver.for :firefox
    driver.navigate.to uri
    wait = Selenium::WebDriver::Wait.new(timeout: 10)
    area = nil
    wait.until { area = driver.find_element(:css, 'span.area'); area.displayed? }
    region = area.text.downcase
  end


  # 下のregion_table をネットから取得する（通常使わない）
  def fetch_region_table
    uri = "https://so-zou.jp/web-app/tech/data/code/japanese-prefecture.htm"
    body = @agent.get uri
    rows = body.search '//tr'
    rows.shift
    array = rows.map do |tr|
      cols = tr.search 'td'
      name = cols[1].text.downcase
      code = cols[2].text.sub(/-0?/, '')
      [name, code]
    end
    Hash[array]
  end

  # 都道府県英語表記から都道府県コードを得る
  def region_table
    @region_table ||= {
      "hokkaido"  => "JP1",
      "aomori"    => "JP2",
      "iwate"     => "JP3",
      "miyagi"    => "JP4",
      "akita"     => "JP5",
      "yamagata"  => "JP6",
      "fukushima" => "JP7",
      "ibaraki"   => "JP8",
      "tochigi"   => "JP9",
      "gunma"     => "JP10",
      "saitama"   => "JP11",
      "chiba"     => "JP12",
      "tokyo"     => "JP13",
      "kanagawa"  => "JP14",
      "niigata"   => "JP15",
      "toyama"    => "JP16",
      "ishikawa"  => "JP17",
      "fukui"     => "JP18",
      "yamanashi" => "JP19",
      "nagano"    => "JP20",
      "gifu"      => "JP21",
      "shizuoka"  => "JP22",
      "aichi"     => "JP23",
      "mie"       => "JP24",
      "shiga"     => "JP25",
      "kyoto"     => "JP26",
      "osaka"     => "JP27",
      "hyogo"     => "JP28",
      "nara"      => "JP29",
      "wakayama"  => "JP30",
      "tottori"   => "JP31",
      "shimane"   => "JP32",
      "okayama"   => "JP33",
      "hiroshima" => "JP34",
      "yamaguchi" => "JP35",
      "tokushima" => "JP36",
      "kagawa"    => "JP37",
      "ehime"     => "JP38",
      "kochi"     => "JP39",
      "fukuoka"   => "JP40",
      "saga"      => "JP41",
      "nagasaki"  => "JP42",
      "kumamoto"  => "JP43",
      "oita"      => "JP44",
      "miyazaki"  => "JP45",
      "kagoshima" => "JP46",
      "okinawa"   => "JP47"
    }
  end


  def prefecture_to_area(prefecture)
    region_table[prefecture] or raise "ERROR! '#{prefecture}' は無効な県名です"
  end


  def regions
    region_table.keys
  end


  def pstore_db
    @db ||= PStore.new(File.join(ENV['HOME'], '.rbtune.db'))
  end


  def save(region)
    stations     = fetch_stations_by_pref(region)
    idlist       = stations.values
    all_stations = fetch_all_stations

    db = pstore_db
    db.transaction do
      db['region']       = region
      db['stations']     = stations
      db['all_stations'] = all_stations
    end
  end


  def load
    db = pstore_db
    region, stations, all_stations = db.transaction(true) do |ps|
      [ps.fetch('region'), ps.fetch('stations'), ps.fetch('all_stations')]
    end
    {region: region, stations: stations, all_stations: all_stations }
  end
end
