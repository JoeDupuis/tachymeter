# frozen_string_literal: true

require "test_helper"
require "tachymeter/html_export"
require "tmpdir"
require "fileutils"
require "securerandom"

class HtmlExportTest < TestCase
  def setup
    @output_path = File.join(Dir.tmpdir, "tachymeter_html_export_#{SecureRandom.hex(8)}.html")
  end

  def teardown
    File.delete(@output_path) if File.exist?(@output_path)
  end

  def test_generates_html_file
    runs = runs("sample")

    Tachymeter::HtmlExport.write(runs, @output_path)
    assert File.exist?(@output_path), "Expected HTML file at #{@output_path}"
  end

  def test_returns_file_path
    runs = runs("sample")

    result = Tachymeter::HtmlExport.write(runs, @output_path)
    assert_equal @output_path, result
  end

  def test_contains_canvas_elements
    runs = runs("sample")

    Tachymeter::HtmlExport.write(runs, @output_path)
    content = File.read(@output_path)
    assert_includes content, '<canvas id="avgCurve"'
    assert_includes content, '<canvas id="totalCurve"'
  end

  def test_embeds_labels_and_data
    runs = runs("sample")

    Tachymeter::HtmlExport.write(runs, @output_path)
    content = File.read(@output_path)
    assert_includes content, runs.map(&:process_count).to_json
    assert_includes content, runs.map(&:average_frequency).to_json
    assert_includes content, runs.map(&:total_frequency).to_json
  end

  def test_uses_default_output_path_when_none_provided
    runs = runs("sample")

    begin
      default_path = Tachymeter::HtmlExport::DEFAULT_OUTPUT
      # Make sure we don't overwrite an existing file
      FileUtils.rm_f(default_path) if File.exist?(default_path)

      result = Tachymeter::HtmlExport.write(runs)
      assert_equal default_path, result
      assert File.exist?(default_path), "Expected HTML file at default path: #{default_path}"
    ensure
      FileUtils.rm_f(default_path) if File.exist?(default_path)
    end
  end
end
