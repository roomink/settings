require 'settings/version'
require 'hashie/mash'
require 'active_support/core_ext/hash/deep_merge'
require 'yaml'

module Settings
  class << self
    def _mash
      @_mash ||= begin
        settings_hash = [
          Environment.root.join('config', 'settings.yml'),
          Environment.root.join('config', 'settings', "#{Environment.to_sym}.yml"),
          Environment.root.join('config', 'settings.local.yml')
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
  end
end
