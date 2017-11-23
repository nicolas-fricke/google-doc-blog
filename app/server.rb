require 'sinatra'
require 'yaml'
require_relative 'config'
require_relative 'google_drive_connector'

get '/' do
  erb :index,
      locals: {
        title: Config[:blog_title],
        docs: GoogleDriveConnector.new.docs,
      }
end
