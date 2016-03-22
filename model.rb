require_relative 'base'
require_relative 'database'
class Model
  include Base
  instance_variable_set(:@configuration, {})
  self.class.__send__(:attr_accessor, :configuration)
  def self.setup(path)
    database = Database.new(path).database
    @configuration[:database] = database
    @configuration[:path] = path
  end
  def self.db
    ret = configuration[:database]
    raise 'No db exists, call setup first!' if ret.nil?
    ret
  end

  def initialize
    super(self.class.configuration[:path])
    @database_params = @params[:database_params]
    @schema = @database_params[:schema]
    self.create
    @keys = @schema[:columns].map{|col| col[:name]}
  end

  def table
    db[@params[:table]]
  end

  def db
    self.class.db
  end

  def create
    table = @database_params[:table]
    schema = @schema
    db.create_table?(table) do 
      primary_key schema[:primary_key]
      Array(schema[:columns]).each { |col| send(col[:type], col[:name]) }
      Array(schema[:indexes]).each do |idx|
        index idx
      end
    end
  end

  def drop 
    db.drop_table?(@database_params[:table])
  end

  def dump
    file_path = @params[:source_path]
    file = File.open(file_path, 'r')
    entries = file.read.split("\n")
    data = entries.map{ |e| transform(e) }
    self.db.run(multi_insert(data))
  end

  def multi_insert(data)
    inserts = data.map do |entry|
      "(#{entry.map{|f| "'#{f}'"}.join(", ")})"
    end
    "INSERT INTO #{@database_params[:table]} #{insert_keys} VALUES #{inserts.join(", ")}"
  end

  def insert_keys
    values = @keys.map {|k| "`#{k}`"}.join(", ")
    "(#{values})"
  end


  def transform(entry)
    size = @schema[:columns].size
    entry.split('|', size)
  end

end
