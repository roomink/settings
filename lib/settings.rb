require 'settings/version'
require 'hashie/mash'
require 'active_support/core_ext/hash/deep_merge'
require 'yaml'
require 'settings/utils'

module Settings
  ENVIRONMENTS = %i(development test staging production)
  
  class << self
    def reload!
      @_mashes = nil
    end
    
    def ai(*args)
      _mashes[Utils.env].ai(*args)
    end
    
    def for(environment)
      _mashes[environment]
    end
    
    def map
      raise ArgumentError, 'Settings.map should be called with a block' unless block_given?
      
      _mashes.each_with_object(Hash.new) do |(environment, mash), hash|
        hash[environment] = yield(mash)
      end
    end
    
  private
    def method_missing(method_name, *args, &block)
      if _mashes[Utils.env].respond_to?(method_name)
        _mashes[Utils.env].send(method_name, &block)
      else
        super
      end
    end
    
    def _mashes
      @_mashes ||= begin
        ENVIRONMENTS.each_with_object(Hash.new) do |environment, hash|
          env_settings = Utils.load_settings_for(environment)
          hash[environment] = Hashie::Mash.new(env_settings)
        end
      end
    end
  end
end
