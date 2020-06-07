require "pstore"

class Station
  attr_reader :name
  attr_reader :id
  attr_reader :ascii_name
  attr_reader :description
  attr_reader :uri

  def self.pstore_db
    @db ||= PStore.new(File.join(ENV['HOME'], '.rbtune.db'))
  end


  def self.list_stations
      Radio.bands.each do |radio|
        name = radio.to_s
        stations = radio.stations
        if stations.nil? || stations.empty?
          $stderr.puts "warning: #{name} に放送局が登録されていません。"
          $stderr.puts "         rbtune --fetch-stations を実行して、放送局情報を取得してください。"
        else
          puts "* #{name}"
          stations.each { |station| puts "    #{station}" }
          puts ''
        end
      end
  end


  def self.fetch_stations
    db = Station::pstore_db
    Radio.bands.each do |radio_class|
      begin
        $stderr.puts ">>> fetching #{radio_class} stations..."
        radio = radio_class.new
        radio.open
        stations = radio.fetch_stations
        if stations.empty?
          $stderr.puts "    warning: no station found."
        else
          db.transaction { db[radio_class.to_s] = stations }
          $stderr.puts "    #{stations.size} stations fetched."
        end

      rescue SocketError
        $stderr.puts $!

      rescue Net::HTTPNotFound
        $stderr.puts $!

      rescue REXML::ParseException
        $stderr.puts $!

      rescue
        # 例外を握りつぶしてすべてのクラスの放送局情報の取得を試みる
        $stderr.puts $!
      end
    end
  end


  def initialize(id, uri, name: '', ascii_name: '', description: '')
    @id          = id.to_s.upcase
    @uri         = uri
    @name        = normalize_name name
    @ascii_name  = ascii_name
    @description = description
  end


  def normalize_name(name)
    # NHKの局名はnormalizeしない (NHKFM-* の-が取れてしまうから)
    return name if name.include?('NHK')
    name.strip
    .sub(/[ -]?FM[ -]?/i, 'FM')
    .sub(/fm|ＦＭ|エフエム|えふえむ/, 'FM')
    .tr('　！＠', ' !@')
  end

  def to_s
    "#{id}:\t\t#{name}\t\t#{ascii_name}"
  end

  alias :inspect :to_s

  def ==(other)
    id == other.id
  end

end