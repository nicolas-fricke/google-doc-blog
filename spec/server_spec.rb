require 'spec_helper'
require_relative '../app/server'

describe 'The web server' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it 'should say hello' do
    get '/'
    expect(last_response).to be_successful
    expect(last_response.body).to eq('Hello World')
  end
end
