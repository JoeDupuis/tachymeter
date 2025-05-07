# frozen_string_literal: true

require_relative "test_helper"
require "pg"
require "mysql2"

class DatabaseConfigTest < TestCase
  def setup
    @sqlite_config_path = File.expand_path("fixtures/sqlite_database.yml", __dir__)
    @postgres_config_path = File.expand_path("fixtures/postgres_database.yml", __dir__)
    @mysql_config_path = File.expand_path("fixtures/mysql_database.yml", __dir__)
    @expected_db_path = File.join(Dir.tmpdir, "tachymeter_test_custom.db")
    File.delete(@expected_db_path) if File.exist?(@expected_db_path)
  end

  def teardown
    File.delete(@expected_db_path) if File.exist?(@expected_db_path)
    Tachymeter.application.setup_default_db
  end

  def test_sqlite_configuration_from_file
    Tachymeter.application.configure_database(@sqlite_config_path)
    Tachymeter.application.create_db

    assert_equal "sqlite3:#{@expected_db_path}", ActiveRecord::Base.connection_db_config.url
    assert File.exist?(@expected_db_path), "Database file should be created"

    config_hash = ActiveRecord::Base.connection_db_config.configuration_hash
    assert_equal 10, config_hash[:pool], "Pool size should be set to 10"
    assert_equal 10000, config_hash[:timeout], "Timeout should be set to 10000"
  end

  def test_postgres_configuration_from_file
      Tachymeter.application.configure_database(@postgres_config_path)

      config_hash = ActiveRecord::Base.connection_db_config.configuration_hash
      assert_equal "postgresql", config_hash[:adapter], "Adapter should be postgresql"
      assert_equal "tachymeter_test", config_hash[:database], "Database name should be tachymeter_test"
      assert_equal "localhost", config_hash[:host], "Host should be localhost"
      assert_equal 5432, config_hash[:port], "Port should be 5432"
      assert_equal 10, config_hash[:pool], "Pool size should be set to 10"
      assert_equal 10000, config_hash[:timeout], "Timeout should be set to 10000"
  end

  def test_mysql_configuration_from_file
      Tachymeter.application.configure_database(@mysql_config_path)

      config_hash = ActiveRecord::Base.connection_db_config.configuration_hash
      assert_equal "mysql2", config_hash[:adapter], "Adapter should be mysql2"
      assert_equal "tachymeter_test", config_hash[:database], "Database name should be tachymeter_test"
      assert_equal "127.0.0.1", config_hash[:host], "Host should be 127.0.0.1"
      assert_equal 3306, config_hash[:port], "Port should be 3306"
      assert_equal "root", config_hash[:username], "Username should be root"
      assert_equal 10, config_hash[:pool], "Pool size should be set to 10"
      assert_equal 10000, config_hash[:timeout], "Timeout should be set to 10000"
  end

  def test_db_config_cli_option
    ARGV.replace([
      "--db-config", @sqlite_config_path,
      "--procs", "1",
      "--timeout", "1"
    ])
    cli = Tachymeter::CLI.new

    output, = capture_io { cli.run }

    assert File.exist?(@expected_db_path), "Database file should be created via CLI"
    assert_match(/Score: \d+/, output)
  end
end
