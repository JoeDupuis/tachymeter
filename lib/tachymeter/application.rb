# frozen_string_literal: true

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

    def configure_database(url: nil, config_file: nil, config_hash: nil)
      db_url = determine_db_url(url, config_file, config_hash)
      return unless db_url

      ENV["DATABASE_URL"] = db_url

      ActiveRecord::Base.connection_handler.clear_all_connections!

      db_configs = ActiveRecord::DatabaseConfigurations.new({
        "production" => { "primary" => { "url" => db_url } }
      })
      ActiveRecord::Base.configurations = db_configs

      ActiveRecord::Base.establish_connection :production

      db_url
    end

    def load_schema
      load Rails.root.join("db/schema.rb")
    end

    private

    def determine_db_url(url, config_file, config_hash)
      return url if url

      if config_hash
        adapter = config_hash[:adapter] || "sqlite3"
        database = config_hash[:database]
        return "#{adapter}:#{database}" if database
      end

      if config_file && File.exist?(config_file)
        return parse_config_file(config_file)
      end

      ENV["DATABASE_URL"]
    end

    def parse_config_file(path)
      require "yaml"
      config = YAML.load_file(path)
      config.dig("production", "url")
    end
  end

  @application = Application.new

  def self.application
    @application
  end
end
