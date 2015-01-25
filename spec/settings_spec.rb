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

describe Settings do
  let(:root) { Pathname.new(__FILE__).join('..') }
  
  describe '.method_missing' do
    before(:each) do
      create_config_files(root)
      allow(Settings::Utils).to receive(:root).and_return(root)
    end
    
    it 'is delegated to a mash for current environment' do
      expect(Settings.redis.db).to eq(0)
      expect(Settings.a_.b_.c).to be_nil
    end
    
    after(:each) do
      remove_config_files(root)
    end
  end
  
  describe '.map' do
    before(:each) do
      create_config_files(root)
      allow(Settings::Utils).to receive(:root).and_return(root)
    end
    
    it 'yields each mash and returns results indexed by environment' do
      expect(Settings.map(&:postgresql)).to eq(
        development: Settings.for(:development).postgresql,
        test:        Settings.for(:test).postgresql,
        staging:     Settings.for(:staging).postgresql,
        production:  Settings.for(:production).postgresql
      )
    end
    
    after(:each) do
      remove_config_files(root)
    end
  end
  
  describe '.for' do
    before(:each) do
      create_config_files(root)
      allow(Settings::Utils).to receive(:root).and_return(root)
    end
    
    it 'returns settings for the specified environment' do
      expect(Settings.for(:test).postgresql.database).to eq('rails_test')
    end
    
    after(:each) do
      remove_config_files(root)
    end
  end
  
  describe '.reload!' do
    before(:each) do
      create_config_files(root)
      allow(Settings::Utils).to receive(:root).and_return(root)
    end
    
    it 'reloads the data from YAML files' do
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
end
