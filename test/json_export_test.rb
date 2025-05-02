# frozen_string_literal: true

require "test_helper"
require "tachymeter/json_export"
require "tmpdir"
require "fileutils"
require "securerandom"
require "json"

class JsonExportTest < TestCase
  def setup
    @output_path = File.join(Dir.tmpdir, "tachymeter_json_export_#{SecureRandom.hex(8)}.json")
  end

  def teardown
    File.delete(@output_path) if File.exist?(@output_path)
  end

  def test_generates_json_file
    runs = runs("sample")

    Tachymeter::JsonExport.write(runs, @output_path)
    assert File.exist?(@output_path), "Expected JSON file at #{@output_path}"
  end

  def test_returns_file_path
    runs = runs("sample")

    result = Tachymeter::JsonExport.write(runs, @output_path)
    assert_equal @output_path, result
  end

  def test_generated_json_is_valid
    runs = runs("sample")

    Tachymeter::JsonExport.write(runs, @output_path)
    assert_nothing_raised do
      JSON.parse(File.read(@output_path))
    end
  end

  def test_json_contains_expected_data
    runs = runs("sample")

    Tachymeter::JsonExport.write(runs, @output_path)
    data = JSON.parse(File.read(@output_path))

    assert data.key?("runs"), "JSON should contain 'runs' key"

    runs.each do |run|
      process_count = run.process_count.to_s
      assert data["runs"].key?(process_count), "JSON should contain data for process_count #{process_count}"

      process_data = data["runs"][process_count]
      assert process_data.key?("process_count"), "Process data should contain 'process_count' key"
      assert process_data.key?("rps_avg"), "Process data should contain 'rps_avg' key"
      assert process_data.key?("rps_sum"), "Process data should contain 'rps_sum' key"

      assert_equal run.process_count, process_data["process_count"]
      assert_equal run.average_frequency, process_data["rps_avg"]
      assert_equal run.total_frequency, process_data["rps_sum"]
    end
  end

  def test_uses_default_output_path_when_none_provided
    runs = runs("sample")

    begin
      default_path = Tachymeter::JsonExport::DEFAULT_OUTPUT
      # Make sure we don't overwrite an existing file
      FileUtils.rm_f(default_path) if File.exist?(default_path)

      result = Tachymeter::JsonExport.write(runs)
      assert_equal default_path, result
      assert File.exist?(default_path), "Expected JSON file at default path: #{default_path}"
    ensure
      FileUtils.rm_f(default_path) if File.exist?(default_path)
    end
  end
end