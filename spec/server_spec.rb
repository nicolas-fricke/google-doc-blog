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
      let(:html) do
        <<~HTML
          <html>
          <head>
            <meta content="text/html; charset=UTF-8" http-equiv="content-type">
            <style type="text/css"></style>
          </head>
          <body style="background-color:#ffffff;padding:72pt 72pt 72pt 72pt;max-width:468pt">
          <h1 id="h.rdp4m3ei7nk6" style="padding-top:20pt;margin:0;color:#000000;padding-left:0;font-size:20pt;padding-bottom:6pt;line-height:1.15;page-break-after:avoid;font-family:&quot;Arial&quot;;orphans:2;widows:2;text-align:left;padding-right:0">
            <span style="color:#000000;font-weight:400;text-decoration:none;vertical-align:baseline;font-size:20pt;font-family:&quot;Arial&quot;;font-style:normal">Simple article</span>
          </h1>
          <p style="padding:0;margin:0;color:#000000;font-size:11pt;font-family:&quot;Arial&quot;;line-height:1.15;orphans:2;widows:2;height:11pt;text-align:left">
            <span style="color:#000000;font-weight:400;text-decoration:none;vertical-align:baseline;font-size:11pt;font-family:&quot;Arial&quot;;font-style:normal"></span>
          </p>
          <p style="padding:0;margin:0;color:#000000;font-size:11pt;font-family:&quot;Arial&quot;;line-height:1.15;orphans:2;widows:2;text-align:left">
            <span style="color:#000000;font-weight:400;text-decoration:none;vertical-align:baseline;font-size:11pt;font-family:&quot;Arial&quot;;font-style:normal">It's nice when it works!</span>
          </p>
          <p style="padding:0;margin:0;color:#000000;font-size:11pt;font-family:&quot;Arial&quot;;line-height:1.15;orphans:2;widows:2;height:11pt;text-align:left">
            <span style="color:#000000;font-weight:400;text-decoration:none;vertical-align:baseline;font-size:11pt;font-family:&quot;Arial&quot;;font-style:normal"></span>
          </p>
          </body>
          </html>
        HTML
      end

      before do
        allow(document_double)
          .to receive(:export_as_string).with('html').and_return(html)
      end

      it 'should return the article page for the given document' do
        get "/#{doc_id}"
        expect(last_response).to be_successful
        expect(last_response.body).to include document_double.title
        expect(last_response.body).to include "It's nice when it works!"
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
