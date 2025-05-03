# frozen_string_literal: true

require "test_helper"

class ScoreTest < TestCase
  def setup
    @results = [
      Tachymeter::Result.new(1, 100.0, "test_1"),
      Tachymeter::Result.new(2, 120.0, "test_2"),
      Tachymeter::Result.new(4, 110.0, "test_4")
    ]
  end

  def test_score_with_default_reference
    score = Tachymeter::Score.new(@results)
    assert_equal 440.0, score.score
  end

  def test_score_with_empty_results
    score = Tachymeter::Score.new([])
    assert_equal 0.0, score.score
  end

  def test_score_with_multiple_reference_machines
    reference_machines = {
      fast: { throughput: 500.0, weight: 2.0 },
      slow: { throughput: 100.0, weight: 1.0 }
    }

    score = Tachymeter::Score.new(@results, reference_machines: reference_machines)
    expected_score = 2053.3
    assert_in_delta expected_score, score.score, 0.1
  end
end
