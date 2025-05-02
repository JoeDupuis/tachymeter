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
end
