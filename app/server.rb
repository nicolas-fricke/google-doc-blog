require 'sinatra'
require 'yaml'
require_relative 'config'

get '/' do
  erb :index, locals: { title: Config[:blog_title] }
end
