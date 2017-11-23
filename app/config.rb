class Config
  class << self
    def [](key)
      config[key]
    end

    def config
      return @config if defined? @config
      @config =
        begin
          YAML.load_file(path)
        rescue Errno::ENOENT
          raise IOError,
                'No config file found. Define it by running `bin/setup.rb`'
        end
    end

    def path
      File.join([File.dirname(__FILE__), '..', 'config', 'config.yml'])
    end
  end
end
