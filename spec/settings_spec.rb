require 'spec_helper'

describe "Settings" do
  before(:each) do
    @root = Pathname.new(File.expand_path('..', __FILE__))
    
    hash = {
      redis: {
        db: 1
      },
      mongo: {
        db: 'lenta_test'
      }
    }
    yaml = YAML.dump(hash)
    
    FileUtils.mkdir(@root + 'config')
    File.open(@root + 'config/settings.yml', 'w') do |file|
      file.write(yaml)
    end
  end
  
  describe "any method" do
    before(:each) do
      Settings.stub(:_root).and_return(@root)
    end
    
    it "is delegated to a mash" do
      Settings.redis.db.should == 1
      Settings.mongo.db.should == 'lenta_test'
      Settings.a_.b_.c.should be_nil
    end
  end
  
  after(:each) do
    FileUtils.rm_r(@root + 'config')
  end
end
