# frozen_string_literal: true

require "test_helper"
require "mocha/minitest"

class CliTest < TestCase
  def test_cli_prints_score_and_stats
    # Fake benchmark results (process_count, avg_rps, run_id)
    mock_results = [
      Tachymeter::Result.new(1, 100.0, "run1"),
      Tachymeter::Result.new(2,  90.0, "run1")
    ]

    Tachymeter::Runner
      .expects(:new)
      .returns(stub(start: mock_results))

    Tachymeter::Scenario
      .stubs(:new)
      .returns(stub(run: nil))

    stdout, = capture_io { Tachymeter::CLI.new([]).run }

    assert_match(/Score:\s+\d+/, stdout)
    assert_match(/Max throughput:/, stdout)
    assert_match(/Max RPS \/ process:/, stdout)
    assert_match(/Mean RPS \/ process across curve:/, stdout)
  end
end