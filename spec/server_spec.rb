require 'spec_helper'
require 'yaml'
require_relative '../app/server'

describe 'The web server' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  let(:blog_title) { 'My Blog' }
  let(:config) { { title: blog_title } }

  before do
    allow(YAML).to receive(:load_file).and_return(config)
    require_relative '../app/app'
  end

  it 'should return the configured blog title' do
    get '/'
    expect(last_response).to be_successful
    expect(last_response.body.strip).to eq(blog_title)
  end
end
