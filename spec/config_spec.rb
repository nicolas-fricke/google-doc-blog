require 'spec_helper'
require 'yaml'
require_relative '../app/config'

describe Config do
  describe '.[]' do
    subject { described_class[key] }

    let(:config) { { blog_title: 'My Blog' } }
    before { described_class.instance_variable_set(:@config, config) }

    context 'when the given key is known' do
      let(:key) { :blog_title }
      it { should eq config[:blog_title] }
    end

    context 'when the given key is unknown' do
      let(:key) { :this_is_not_in_there }
      it { should eq nil }
    end
  end

  describe '.config' do
    subject { described_class.config }

    context 'when the `@config` class variable has not been set yet' do
      let(:config) { { blog_title: 'My Blog' } }
      before do
        allow(YAML).to(
          receive(:load_file)
            .with(end_with('app/../config/config.yml'))
            .and_return(config)
        )

        if described_class.instance_variables.include?(:@config)
          described_class.remove_instance_variable(:@config)
        end
      end

      it { should eq config }

      it 'should set the `@config` class variable' do
        expect { subject }.to(
          change { described_class.instance_variable_get(:@config) }
            .from(nil)
            .to(config)
        )
      end
    end

    context 'when the `@config` class variable has already been set' do
      let(:previously_set_config) { { blog_title: 'I was already here' } }
      before do
        described_class.instance_variable_set(:@config, previously_set_config)
      end

      it { should eq previously_set_config }
    end
  end

  describe '.path' do
    subject { described_class.path }
    it { should be_a String }
    it { should end_with 'app/../config/config.yml' }
  end
end
