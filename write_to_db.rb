require_relative 'data_source'
require_relative 'model'
require 'sequel'

if __FILE__ == $0
  return if ARGV.size != 2
  ds = DataSource.new(ARGV[0])

  Model.setup(ARGV[0])
  model = Model.new
  model.create

  case ARGV[1].to_s.downcase
  when 'dump'
    ds.load
    model.dump
  when 'drop'
    model.drop
  end
end
