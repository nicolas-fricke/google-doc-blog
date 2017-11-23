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

  let(:document_double_1) do
    double 'document_1',
           modified_time: DateTime.now - 3, # 3 days ago
           title: 'My first document'
  end
  let(:document_double_2) do
    double 'document_2',
           modified_time: DateTime.now - 1, # 1 day ago
           title: 'New stuff'
  end
  let(:docs) { [document_double_1, document_double_2] }
  let(:drive_connector_double) { double('drive_connector', docs: docs) }

  before do
    Config.instance_variable_set(:@config, config)
    allow(GoogleDriveConnector)
      .to receive(:new).and_return(drive_connector_double)
  end

  describe 'GET /' do
    it 'should return the blog index page' do
      get '/'
      expect(last_response).to be_successful
      expect(last_response.body).to include blog_title
      expect(last_response.body).to include document_double_1.title,
                                            document_double_2.title
    end
  end
end
