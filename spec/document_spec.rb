require 'spec_helper'
require_relative '../app/document'

describe Document do
  let(:user_double) { double 'user', display_name: 'Us Er' }
  let(:modified_time) { DateTime.parse('2017-11-24T12:39:41') }
  let(:google_doc_double) do
    double 'document',
           id: 'd0c_1d',
           modified_time: modified_time,
           title: 'My first document',
           last_modifying_user: user_double
  end
  let(:instance) { described_class.new(google_doc_double) }
  let(:html) { File.read('spec/fixtures/google_doc.html') }

  before do
    allow(google_doc_double)
      .to receive(:export_as_string).with('html').and_return(html)
  end

  describe '#id' do
    subject { instance.id }
    it { should eq google_doc_double.id }
  end

  describe '#title' do
    subject { instance.title }
    it { should eq google_doc_double.title }
  end

  describe '#modified_time' do
    subject { instance.modified_time }
    it { should eq google_doc_double.modified_time }
  end

  describe '#modified_time_display' do
    subject { instance.modified_time_display }
    it { should eq '24 Nov 2017' }
  end

  describe '#last_author_name' do
    subject { instance.last_author_name }
    it { should eq user_double.display_name }
  end

  describe '#html_body' do
    subject { instance.html_body }
    it { should be_a String }
    it { should include "It's nice when it works!" }
  end
end
