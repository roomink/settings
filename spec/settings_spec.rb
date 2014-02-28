require 'spec_helper'

def create_config_files(root)
  FileUtils.mkdir_p(root + 'config' + 'settings')
  
  settings = {
    'settings.yml' => {
      postgresql: {
        adapter:  'postgresql',
        encoding: 'unicode'
      },
      redis: {
        host: 'localhost',
        port: 6379
      }
    },
    'settings/development.yml' => {
      postgresql: { database: 'rails_development' },
      redis:      { db: 0 }
    },
    'settings/test.yml' => {
      postgresql: { database: 'rails_test' },
      redis:      { db: 1 }
    },
    'settings/staging.yml' => {
      postgresql: { database: 'rails_staging' },
      redis:      { db: 2 }
    },
    'settings/production.yml' => {
      postgresql: { database: 'rails_production' },
      redis:      { db: 3 }
    },
    'settings/development.local.yml' => {
      postgresql: { database: 'rails' }
    }
  }
  
  settings.each do |filename, settings_hash|
    yaml = YAML.dump(settings_hash)
    
    File.open(root + 'config' + filename, 'w') do |file|
      file.write(yaml)
    end
  end
end

def remove_config_files(root)
  FileUtils.rm_r(root + 'config')
end

def stub_rails
  rails = double("Rails", root: root, env: :production)
  Object.const_set(:Rails, rails)
end

def unstub_rails
  Object.send(:remove_const, :Rails)
end

describe Settings do
  let(:root) { Pathname.new(__FILE__).join('..') }
  
  describe ".method_missing" do
    before(:each) do
      create_config_files(root)
      Settings.stub(:_root).and_return(root)
    end
    
    it "is delegated to a mash" do
      expect(Settings.redis.db).to eq(0)
      expect(Settings.a_.b_.c).to be_nil
    end
    
    after(:each) do
      remove_config_files(root)
    end
  end
  
  describe ".reload!" do
    before(:each) do
      create_config_files(root)
      Settings.stub(:_root).and_return(root)
    end
    
    it "reloads the data from YAML files" do
      expect(Settings.redis.db).to eq(0)
      
      File.open(root + 'config/settings/development.yml', 'w') do |file|
        file.write YAML.dump(redis: { db: 2 })
      end
      
      Settings.reload!
      expect(Settings.redis.db).to eq(2)
    end
    
    after(:each) do
      remove_config_files(root)
    end
  end
  
  describe "._root" do
    context "with rails" do
      before(:each) do
        stub_rails
      end
      
      it "returns Rails.root" do
        expect(Settings.send(:_root)).to eq(root)
      end
      
      after(:each) do
        unstub_rails
      end
    end
    
    context "without rails" do
      it "returns Dir.pwd" do
        expected_root = Pathname.new(Dir.pwd)
        expect(Settings.send(:_root)).to eq(expected_root)
      end
    end
  end
  
  describe "._env" do
    context "with rails" do
      before(:each) do
        stub_rails
      end
      
      it "returns Rails.env" do
        expect(Settings.send(:_env)).to eq(:production)
      end
      
      after(:each) do
        unstub_rails
      end
    end
    
    context "with RAILS_ENV" do
      before(:each) do
        ENV['RAILS_ENV'] = 'staging'
      end
      
      it "returns RAILS_ENV" do
        expect(Settings.send(:_env)).to eq(:staging)
      end
      
      after(:each) do
        ENV.delete('RAILS_ENV')
      end
    end
    
    context "without anything" do
      it "returns :development" do
        expect(Settings.send(:_env)).to eq(:development)
      end
    end
  end
end
