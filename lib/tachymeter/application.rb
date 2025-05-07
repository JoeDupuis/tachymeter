# frozen_string_literal: true

require "yaml"
require "erb"
require "securerandom"
require "tmpdir"


module Tachymeter
  class Application
    attr_reader :rails_app

    def initialize(env = ENV["RAILS_ENV"] || "production")
      ENV["RAILS_ENV"] = env
      ENV["DATABASE_URL"] ||= "sqlite3::memory:"

      require "dummy/config/environment"

      @rails_app = Rails.application
      @rails_app.initialize!
    end

    def setup_default_db
      return ENV["DATABASE_URL"] if ENV["DATABASE_URL"] && ENV["DATABASE_URL"] != "sqlite3::memory:"

      temp_dir = Dir.tmpdir
      db_name = "tachymeter_#{SecureRandom.hex(6)}.db"
      temp_db_path = File.join(temp_dir, db_name)

      configure_database("sqlite3:#{temp_db_path}")

      temp_db_path
    end

    def configure_database(config = nil)
      db_config =
        case config
        when Hash
          config
        when String
          if File.exist?(config)
            parse_config_file(config)
          else
            { "url" => config }
          end
        else
          return nil
        end

      db_url = determine_db_url(db_config)
      return unless db_url

      ActiveRecord::Base.connection_handler.clear_all_connections!

      db_configs = ActiveRecord::DatabaseConfigurations.new({
        "production" => { "primary" => {
          "url" => db_url,
          "pool" => db_config["pool"] || ENV.fetch("RAILS_MAX_THREADS") { 5 },
          "timeout" => db_config["timeout"] || 5000
        } }
      })
      ActiveRecord::Base.configurations = db_configs

      ActiveRecord::Base.establish_connection :production

      db_url
    end

    def create_db
      ActiveRecord::Tasks::DatabaseTasks.create_all
    end

    def load_schema
      ActiveRecord::Tasks::DatabaseTasks.load_schema_current(ActiveRecord.schema_format, ENV["SCHEMA"])
    end

    def seed
      ActiveRecord::Tasks::DatabaseTasks.load_seed
    end

    private

    def determine_db_url(config)
      return config["url"] if config["url"]

      if config["adapter"] && config["database"]
        adapter = config["adapter"]
        database = config["database"]

        if adapter == "postgresql" && config["host"]
          port = config["port"] || 5432
          return "#{adapter}://#{config["host"]}:#{port}/#{database}"
        end

        return "#{adapter}:#{database}"
      end

      ENV["DATABASE_URL"]
    end

    def parse_config_file(path)
      content = File.read(path)
      yaml = ERB.new(content).result
      config = YAML.load(yaml)

      config["production"] || {}
    end
  end

  @application = Application.new

  def self.application
    @application
  end
end
