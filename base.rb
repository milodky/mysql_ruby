module Base
  def initialize(path)
    path = File.expand_path("../#{path}", __FILE__)
    @params = YAML.load_file(path).with_indifferent_access
  end
end

