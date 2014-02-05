require 'spec_helper'

def create_config(root)
  hash = {
    redis: {
      db: 1
    },
    mongo: {
      db: 'lenta_test'
    }
  }
  yaml = YAML.dump(hash)
  
  FileUtils.mkdir(root + 'config')
  File.open(root + 'config/settings.yml', 'w') do |file|
    file.write(yaml)
  end
end

describe "Settings" do
  let(:root) { Pathname.new(__FILE__).join('..') }
  
  describe ".method_missing" do
    before(:each) do
      create_config(root)
      Settings.stub(:_root).and_return(root)
    end
    
    it "is delegated to a mash" do
      expect(Settings.redis.db).to eq(1)
      expect(Settings.mongo.db).to eq('lenta_test')
      expect(Settings.a_.b_.c).to be_nil
    end
    
    after(:each) do
      FileUtils.rm_r(root + 'config')
    end
  end
end
