module Settings
  module Utils
    class << self
      def load_settings_for(environment)
        paths_for(environment).map do |path|
          read_file(path)
        end.compact.inject({}, :deep_merge)
      end
      
      def paths_for(environment)
        [
          %w(settings.yml),
          %W(settings #{environment}.yml),
          %w(settings.local.yml),
          %W(settings #{environment}.local.yml)
        ].map do |path_parts|
          root.join('config', *path_parts)
        end.select(&:exist?)
      end
      
      def read_file(path)
        yaml = File.read(path)
        YAML.load(yaml) unless yaml.empty?
      end
      
      def env
        if rails?
          Rails.env
        elsif ENV['RAILS_ENV']
          ENV['RAILS_ENV']
        elsif ENV['RACK_ENV']
          ENV['RACK_ENV']
        else
          :development
        end.to_sym
      end
      
      def rails?
        const_defined?(:Rails)
      end
      
      def root
        rails_root || pwd
      end
      
      def rails_root
        Rails.root if rails?
      end
      
      def pwd
        Pathname.new(Dir.pwd)
      end
    end
  end
end
