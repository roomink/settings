require 'settings/version'
require 'hashie/mash'
require 'active_support/core_ext/hash/deep_merge'
require 'yaml'

module Settings
  ENVIRONMENTS = %i(development test staging production)
  
  class << self
    def reload!
      @_mashes = nil
    end
    
    def ai
      _mashes[_env].ai
    end
    
    def for(environment)
      _mashes[environment]
    end
    
  private
    def method_missing(method_name, *args, &block)
      if _mashes[_env].respond_to?(method_name)
        _mashes[_env].send(method_name, &block)
      else
        super
      end
    end
    
    def _mashes
      @_mashes ||= begin
        ENVIRONMENTS.each_with_object(Hash.new) do |environment, hash|
          env_settings = _load_settings_for(environment)
          hash[environment] = Hashie::Mash.new(env_settings)
        end
      end
    end
    
    def _load_settings_for(environment)
      _paths_for(environment).map do |path|
        _read_file(path)
      end.compact.inject({}, :deep_merge)
    end
    
    def _paths_for(environment)
      [
        %w(settings.yml),
        %W(settings #{environment}.yml),
        %w(settings.local.yml),
        %W(settings #{environment}.local.yml)
      ].map do |path_parts|
        _root.join('config', *path_parts)
      end.select(&:exist?)
    end
    
    def _read_file(path)
      yaml = File.read(path)
      YAML.load(yaml) unless yaml.empty?
    end
    
    def _root
      if _rails?
        Rails.root
      else
        Pathname.new(Dir.pwd)
      end
    end
    
    def _env
      if _rails?
        Rails.env
      elsif ENV['RAILS_ENV']
        ENV['RAILS_ENV'].to_sym
      else
        :development
      end
    end
    
    def _rails?
      const_defined?(:Rails)
    end
  end
end
