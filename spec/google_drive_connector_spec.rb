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
             title: 'Older Document',
             resource_type: 'document',
             modified_time: DateTime.now - 3 # 3 days ago
    end
    let(:newer_document_double) do
      double 'newer_document',
             title: 'Newer Document',
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

    it 'should return the right documents' do
      is_expected.to be_an Array
      is_expected.to all be_a Document
      titles = subject.map(&:title)
      expect(titles).to contain_exactly older_document_double.title,
                                        newer_document_double.title
      expect(titles).to eq [newer_document_double.title,
                            older_document_double.title]
    end
  end

  describe '#doc' do
    let(:doc_id) { 'd0c-1d' }
    subject { described_class.new.doc(doc_id) }

    context 'when the `doc_id` exists' do
      let(:folder_id) { '123abc' }
      let(:document_double) do
        double('document', id: doc_id, parents: document_parents)
      end

      before do
        allow(Config).to receive(:[]).with(:folder_id).and_return(folder_id)
        allow(session_double).to(
          receive(:file_by_id).with(doc_id).and_return(document_double)
        )
      end

      context 'and it is in the right folder' do
        let(:document_parents) { [folder_id] }
        it 'should return the wrapped document' do
          is_expected.to be_a Document
          expect(subject.id).to eq doc_id
        end
      end

      context 'but it is not in the right folder' do
        let(:document_parents) { ['qwe987'] }
        it { should eq nil }
      end
    end

    context 'when the `doc_id` does not exist' do
      before do
        allow(session_double).to(
          receive(:file_by_id)
            .with(doc_id)
            .and_raise(Google::Apis::ClientError, 'File not found')
        )
      end

      it { should eq nil }
    end
  end
end
