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


  def self.show_stations
      Radio.bands.each do |radio|
        name = radio.to_s
        puts "* #{name}"
        stations = radio.stations
        stations.each { |station| puts "    #{station}" } if stations
        puts ''
      end
  end


  def self.fetch_stations
    db = Station::pstore_db
    Radio.bands.each do |radio_class|
      $stderr.puts "fetching #{radio_class} stations..."
      radio = radio_class.new
      radio.open
      stations = radio.fetch_stations
      db.transaction { db[radio_class.to_s] = stations }
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
    name.strip
    .sub(/[ -]?FM[ -]?/i, 'FM')
    .sub(/fm|ＦＭ|エフエム|えふえむ/, 'FM')
    # .sub(/[(（].*?[）)]/, '')
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