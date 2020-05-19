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
    @name        = name
    @ascii_name  = ascii_name
    @description = description
  end

  def inspect
    "#{id}: '#{name}' [#{ascii_name}] --> #{uri}"
  end


  alias :to_s :inspect
end