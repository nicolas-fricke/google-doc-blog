require 'spec_helper'
require_relative '../app/google_drive_connector'

describe GoogleDriveConnector do
  let(:session_double) { double('session') }

  before do
    allow(GoogleDrive::Session).to(
      receive(:from_config)
        .with(end_with('../config/google.json'))
        .and_return(session_double)
    )
  end

  describe '#docs' do
    subject { described_class.new.docs }

    let(:folder_id) { '123abc' }
    let(:folder_double) { double('folder') }

    let(:older_document_double) do
      double 'older_document',
             resource_type: 'document',
             modified_time: DateTime.now - 3 # 3 days ago
    end
    let(:newer_document_double) do
      double 'newer_document',
             resource_type: 'document',
             modified_time: DateTime.now - 1 # 1 day ago
    end

    let(:file_doubles) do
      [
        older_document_double,
        double('other_file', resource_type: 'file'),
        newer_document_double,
        double('spreadsheet', resource_type: 'spreadsheet'),
      ]
    end

    before do
      allow(Config).to receive(:[]).with(:folder_id).and_return(folder_id)
      allow(session_double)
        .to receive(:file_by_id).with(folder_id).and_return(folder_double)
      allow(folder_double).to receive(:files).and_return(file_doubles)
    end

    it { should be_an Array }
    it { should contain_exactly older_document_double, newer_document_double }
    it { should eq [newer_document_double, older_document_double] }
  end
end
