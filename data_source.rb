require 'active_support/all'
require 'yaml'
require 'faker'
require_relative 'base'
class DataSource
  DATA_SET = {
  }.with_indifferent_access
  include Base
  DEFAULT_SIZE = 10
  def initialize(path)
    super
    @keys = @params[:keys]
    @size = @params[:size]
    @keys.each do |config|
      key = config[:key]
      type = config[:type]
      size = config[:size] || DEFAULT_SIZE

      DATA_SET[key] ||= []
      1.upto(size) do
        DATA_SET[key] << Faker.const_get(type).send(key)
      end
    end
    
  end

  
  
  def load
    file = File.open(@params[:source_path], 'w')
    1.upto(@size) do 
      value = @keys.map do |k|
        key = k[:key]
        DATA_SET[key].sample
      end.join('|').downcase
      file.puts(value)
    end
    file.close
  end
end
