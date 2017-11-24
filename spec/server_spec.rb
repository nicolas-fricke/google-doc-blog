require 'spec_helper'
require 'yaml'
require_relative '../app/config'
require_relative '../app/server'

describe 'The web server' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  let(:blog_title) { 'My Blog' }
  let(:config) { { blog_title: blog_title } }

  let(:drive_connector_double) { double('drive_connector') }

  before do
    Config.instance_variable_set(:@config, config)
    allow(GoogleDriveConnector)
      .to receive(:new).and_return(drive_connector_double)
  end

  describe 'GET /' do
    let(:document_1) do
      Document.new(
        double 'document_1',
               id: 'd0cum3nt-1',
               modified_time: DateTime.now - 3, # 3 days ago
               title: 'My first document'
      )
    end
    let(:document_2) do
      Document.new(
        double 'document_2',
               id: 'd0cum3nt-2',
               modified_time: DateTime.now - 1, # 1 day ago
               title: 'New stuff'
      )
    end
    let(:docs) { [document_1, document_2] }

    before { allow(drive_connector_double).to receive(:docs).and_return(docs) }

    it 'should return the blog index page' do
      get '/'
      expect(last_response).to be_successful
      expect(last_response.body).to include blog_title
      expect(last_response.body).to include document_1.title,
                                            document_2.title
    end
  end

  describe 'GET /:document_id' do
    let(:doc_id) { 'd0cum3nt' }

    before do
      allow(drive_connector_double)
        .to receive(:doc).with(doc_id).and_return(document)
    end

    context 'when there is a document for the given ID' do
      let(:user_double) { double 'user', display_name: 'Us Er' }
      let(:google_doc_double) do
        double 'document',
               id: doc_id,
               modified_time: DateTime.now - 3, # 3 days ago
               title: 'My first document',
               last_modifying_user: user_double
      end
      let(:document) { Document.new(google_doc_double) }
      let(:html) { File.read('spec/fixtures/google_doc.html') }

      before do
        allow(google_doc_double)
          .to receive(:export_as_string).with('html').and_return(html)
      end

      it 'should return the article page for the given document' do
        get "/#{doc_id}"
        expect(last_response).to be_successful
        expect(last_response.body).to include document.title
        expect(last_response.body).to include "It's nice when it works!"
      end
    end

    context 'when there is no document for the given ID' do
      let(:document) { nil }

      it 'should return a 404 error' do
        get "/#{doc_id}"
        expect(last_response).to_not be_successful
        expect(last_response).to be_not_found
      end
    end
  end

  describe 'GET /:document_id/amp' do
    let(:doc_id) { 'd0cum3nt' }

    before do
      allow(drive_connector_double)
        .to receive(:doc).with(doc_id).and_return(document)
    end

    context 'when there is a document for the given ID' do
      let(:user_double) { double 'user', display_name: 'Us Er' }
      let(:google_doc_double) do
        double 'document',
               id: doc_id,
               modified_time: DateTime.now - 3, # 3 days ago
               title: 'My first document',
               last_modifying_user: user_double
      end
      let(:document) { Document.new(google_doc_double) }
      let(:html) { File.read('spec/fixtures/google_doc.html') }

      before do
        allow(google_doc_double)
          .to receive(:export_as_string).with('html').and_return(html)
      end

      it 'should return the article page for the given document' do
        get "/#{doc_id}/amp"
        expect(last_response).to be_successful
        expect(last_response.body).to include document.title
        expect(last_response.body).to include "It's nice when it works!"
        expect(last_response.body).to include 'https://cdn.ampproject.org/v0.js'
      end
    end

    context 'when there is no document for the given ID' do
      let(:document) { nil }

      it 'should return a 404 error' do
        get "/#{doc_id}"
        expect(last_response).to_not be_successful
        expect(last_response).to be_not_found
      end
    end
  end
end
