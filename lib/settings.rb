require 'settings/version'
require 'hashie/mash'
require 'active_support/core_ext/hash/deep_merge'
require 'yaml'

module Settings
  class << self
    def reload!
      @_mash = nil
    end
    
    def ai
      _mash.ai
    end
    
  private
    def _mash
      @_mash ||= begin
        settings_hash = _paths.map do |path|
          yaml = File.read(path)
          YAML.load(yaml) unless yaml.empty?
        end.compact.inject({}, :deep_merge)
        
        Hashie::Mash.new(settings_hash)
      end
    end
    
    def _paths
      [
        %w(settings.yml),
        %W(settings #{_env}.yml),
        %w(settings.local.yml),
        %W(settings #{_env}.local.yml)
      ].map do |path_parts|
        _root.join('config', *path_parts)
      end.select(&:exist?)
    end
    
    def method_missing(method_name, *args, &block)
      if _mash.respond_to?(method_name)
        _mash.send(method_name, &block)
      else
        super
      end
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
