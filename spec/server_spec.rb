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
    let(:document_double_1) do
      double 'document_1',
             id: 'd0cum3nt-1',
             modified_time: DateTime.now - 3, # 3 days ago
             title: 'My first document'
    end
    let(:document_double_2) do
      double 'document_2',
             id: 'd0cum3nt-2',
             modified_time: DateTime.now - 1, # 1 day ago
             title: 'New stuff'
    end
    let(:docs) { [document_double_1, document_double_2] }

    before { allow(drive_connector_double).to receive(:docs).and_return(docs) }

    it 'should return the blog index page' do
      get '/'
      expect(last_response).to be_successful
      expect(last_response.body).to include blog_title
      expect(last_response.body).to include document_double_1.title,
                                            document_double_2.title
    end
  end

  describe 'GET /:document_id' do
    let(:doc_id) { 'd0cum3nt' }

    before do
      allow(drive_connector_double)
        .to receive(:doc).with(doc_id).and_return(document_double)
    end

    context 'when there is a document for the given ID' do
      let(:user_double) { double 'user', display_name: 'Us Er' }
      let(:document_double) do
        double 'document_1',
               id: doc_id,
               modified_time: DateTime.now - 3, # 3 days ago
               title: 'My first document',
               last_modifying_user: user_double
      end

      it 'should return the article page for the given document' do
        get "/#{doc_id}"
        expect(last_response).to be_successful
        expect(last_response.body).to include document_double.title
      end
    end

    context 'when there is no document for the given ID' do
      let(:document_double) { nil }

      it 'should return a 404 error' do
        get "/#{doc_id}"
        expect(last_response).to_not be_successful
        expect(last_response).to be_not_found
      end
    end
  end
end
