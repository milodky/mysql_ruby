require_relative 'base'
class Database
  include Base
  attr_accessor :database
  def initialize(path)
    super
    @db_params = @params[:database_params]
    @database = Sequel.connect(:adapter => 'mysql', 
                        :user => @db_params[:user],
                        :host => @db_params[:host],
                        :database => @db_params[:database],
                       )
  end

end
