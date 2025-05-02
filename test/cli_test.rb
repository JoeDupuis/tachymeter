# frozen_string_literal: true

require "test_helper"
require "mocha/minitest"
require "tmpdir"
require "securerandom"

class CliTest < TestCase
  def setup
    @output_path = File.join(Dir.tmpdir, "tachymeter_cli_test_#{SecureRandom.hex(8)}.html")
    @json_path = File.join(Dir.tmpdir, "tachymeter_cli_test_#{SecureRandom.hex(8)}.json")
  end

  def teardown
    File.delete(@output_path) if File.exist?(@output_path)
    File.delete(@json_path) if File.exist?(@json_path)
  end

  def test_cli_prints_score_and_stats
    runs = runs("sample")

    Tachymeter::Runner
      .expects(:new)
      .returns(stub(start: runs))

    Tachymeter::Scenario
      .stubs(:new)
      .returns(stub(run: nil))

    stdout, = capture_io { Tachymeter::CLI.new([]).run }

    assert_match(/Score:\s+\d+/, stdout)
    assert_match(/Max throughput:/, stdout)
    assert_match(/Max RPS \/ process:/, stdout)
    assert_match(/Mean RPS \/ process across curve:/, stdout)
  end

  def test_cli_exports_with_e_option_custom_path
    runs = runs("sample")

    Tachymeter::Runner
      .expects(:new)
      .returns(stub(start: runs))

    Tachymeter::Scenario
      .stubs(:new)
      .returns(stub(run: nil))

    Tachymeter::HtmlExport
      .expects(:write)
      .with(runs, @output_path)
      .returns(@output_path)

    stdout, = capture_io { Tachymeter::CLI.new(["-e", @output_path]).run }

    assert_match(/Results exported to HTML:/, stdout)
  end

  def test_cli_exports_with_export_option_default_path
    runs = runs("sample")
    default_path = Tachymeter::HtmlExport::DEFAULT_OUTPUT

    Tachymeter::Runner
      .expects(:new)
      .returns(stub(start: runs))

    Tachymeter::Scenario
      .stubs(:new)
      .returns(stub(run: nil))

    Tachymeter::HtmlExport
      .expects(:write)
      .with(runs, default_path)
      .returns(default_path)

    stdout, = capture_io { Tachymeter::CLI.new(["--export"]).run }

    assert_match(/Results exported to HTML:/, stdout)
  end

  def test_cli_exports_with_format_option
    runs = runs("sample")

    Tachymeter::Runner
      .expects(:new)
      .returns(stub(start: runs))

    Tachymeter::Scenario
      .stubs(:new)
      .returns(stub(run: nil))

    Tachymeter::JsonExport
      .expects(:write)
      .with(runs, @json_path)
      .returns(@json_path)

    stdout, = capture_io { Tachymeter::CLI.new(["--export", @json_path, "--format", "json"]).run }

    assert_match(/Results exported to JSON:/, stdout)
  end
end
