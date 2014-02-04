require 'settings/version'
require 'hashie/mash'
require 'active_support/core_ext/hash/deep_merge'
require 'yaml'

module Settings
  class << self
    def _mash
      @_mash ||= begin
        settings_hash = [
          _root.join('config', 'settings.yml'),
          _root.join('config', 'settings', "#{_env}.yml"),
          _root.join('config', 'settings.local.yml')
        ].select(&:exist?).map do |path|
          yaml = File.read(path)
          YAML.load(yaml) unless yaml.empty?
        end.compact.inject({}, :deep_merge)
        
        Hashie::Mash.new(settings_hash)
      end
    end
    
    def method_missing(method_name, *args, &block)
      if _mash.respond_to?(method_name)
        _mash.send(method_name, &block)
      else
        super
      end
    end
    
  private
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
        ENV['RAILS_ENV']
      else
        :development
      end
    end
    
    def _rails?
      const_defined?(:Rails)
    end
  end
end
