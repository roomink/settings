require 'spec_helper'

def stub_rails
  rails = double('Rails', root: root, env: :production)
  Object.const_set(:Rails, rails)
end

def unstub_rails
  Object.send(:remove_const, :Rails)
end

describe Settings::Utils do
  let(:root) { Pathname.new(__FILE__).join('..') }
  
  describe '.root' do
    context 'with rails' do
      before(:each) do
        stub_rails
      end
      
      it 'returns Rails.root' do
        expect(Settings::Utils.root).to eq(root)
      end
      
      after(:each) do
        unstub_rails
      end
    end
    
    context 'without rails' do
      it 'returns Dir.pwd' do
        expected_root = Pathname.new(Dir.pwd)
        expect(Settings::Utils.root).to eq(expected_root)
      end
    end
  end
  
  describe '.env' do
    context 'with rails' do
      before(:each) do
        stub_rails
      end
      
      it 'returns Rails.env' do
        expect(Settings::Utils.env).to eq(:production)
      end
      
      after(:each) do
        unstub_rails
      end
    end
    
    context 'with RAILS_ENV' do
      before(:each) do
        ENV['RAILS_ENV'] = 'staging'
      end
      
      it 'returns RAILS_ENV' do
        expect(Settings::Utils.env).to eq(:staging)
      end
      
      after(:each) do
        ENV.delete('RAILS_ENV')
      end
    end
    
    context 'with RACK_ENV' do
      before(:each) do
        ENV['RACK_ENV'] = 'staging'
      end
      
      it 'returns RACK_ENV' do
        expect(Settings::Utils.env).to eq(:staging)
      end
      
      after(:each) do
        ENV.delete('RACK_ENV')
      end
    end
    
    context 'without anything' do
      it 'returns :development' do
        expect(Settings::Utils.env).to eq(:development)
      end
    end
  end
end
