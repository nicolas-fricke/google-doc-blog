require 'sinatra'
require 'yaml'

current_dir = File.dirname(__FILE__)
config = YAML.load_file(File.join([current_dir, '..', 'config', 'config.yml']))

get '/' do
  erb :index, locals: { title: config[:title] }
end
