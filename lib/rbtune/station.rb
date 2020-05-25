class Station
  attr_reader :name
  attr_reader :id
  attr_reader :ascii_name
  attr_reader :description
  attr_reader :uri

  def self.pstore_db
    @db ||= PStore.new(File.join(ENV['HOME'], '.rbtune.db'))
  end

  def initialize(id, uri, name: '', ascii_name: '', description: '')
    @id          = id.downcase
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

  def inspect
    "#{name}: #{id}: '#{name}' [#{ascii_name}]"
  end


  def to_s
    "#{id}:\t\t#{name}"
  end

end