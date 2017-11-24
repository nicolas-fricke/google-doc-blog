require 'sinatra'
require 'yaml'
require 'article_json'
require_relative 'config'
require_relative 'google_drive_connector'

get '/' do
  erb :index,
      locals: {
        title: Config[:blog_title],
        docs: GoogleDriveConnector.new.docs,
      }
end

get '/:document_id' do
  doc = GoogleDriveConnector.new.doc(params[:document_id])
  halt 404 unless doc
  erb :'show.html',
      locals: {
        blog_title: Config[:blog_title],
        doc: doc,
      }
end

get '/:document_id/amp' do
  doc = GoogleDriveConnector.new.doc(params[:document_id])
  halt 404 unless doc
  erb :'show.amp',
      locals: {
        blog_title: Config[:blog_title],
        doc: doc,
        header_tags: doc.amp_libraries.join(''),
      }
end
