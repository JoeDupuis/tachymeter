# frozen_string_literal: true

require_relative "test_helper"
require "mocha/minitest"

class ScenarioOrchestratorTest < TestCase
  def test_shuffle_provides_deterministic_ordering
    seed = 42
    scenarios1 = Array.new(20) { |i| i }
    scenarios2 = Array.new(20) { |i| i }

    orchestrator1 = Tachymeter::ScenarioOrchestrator.new(scenarios: scenarios1, seed: seed)
    orchestrator2 = Tachymeter::ScenarioOrchestrator.new(scenarios: scenarios2, seed: seed)

    result1 = orchestrator1.shuffle!(5)
    result2 = orchestrator2.shuffle!(5)

    assert_equal result1, result2
  end

  def test_shuffle_with_different_fork_indices_produces_different_orderings
    seed = 42
    scenarios1 = Array.new(20) { |i| i }
    scenarios2 = Array.new(20) { |i| i }

    orchestrator1 = Tachymeter::ScenarioOrchestrator.new(scenarios: scenarios1, seed: seed)
    orchestrator2 = Tachymeter::ScenarioOrchestrator.new(scenarios: scenarios2, seed: seed)

    result1 = orchestrator1.shuffle!(1)
    result2 = orchestrator2.shuffle!(2)

    assert_not_equal result1, result2
  end

  def test_run_scenario_executes_scenarios_in_expected_order
    scenario1 = mock("scenario1_class")
    scenario2 = mock("scenario2_class")
    scenario3 = mock("scenario3_class")

    instance1 = mock("instance1")
    instance2 = mock("instance2")
    instance3 = mock("instance3")

    scenario1.expects(:new).returns(instance1)
    scenario2.expects(:new).returns(instance2)
    scenario3.expects(:new).returns(instance3)

    instance1.expects(:run).returns(:result1)
    instance2.expects(:run).returns(:result2)
    instance3.expects(:run).returns(:result3)

    orchestrator = Tachymeter::ScenarioOrchestrator.new(
      scenarios: [ scenario1, scenario2, scenario3 ]
    )

    assert_equal :result1, orchestrator.run_scenario(0)
    assert_equal :result2, orchestrator.run_scenario(1)
    assert_equal :result3, orchestrator.run_scenario(2)

    instance1_again = mock("instance1_again")
    scenario1.expects(:new).returns(instance1_again)
    instance1_again.expects(:run).returns(:result1_again)

    assert_equal :result1_again, orchestrator.run_scenario(3)
  end

  def test_run_scenario_uses_shuffled_order
    scenario1 = mock("scenario1_class")
    scenario2 = mock("scenario2_class")
    scenario3 = mock("scenario3_class")

    instance1 = mock("instance1")
    instance2 = mock("instance2")
    instance3 = mock("instance3")

    scenario1.expects(:new).returns(instance1)
    scenario2.expects(:new).returns(instance2)
    scenario3.expects(:new).returns(instance3)

    instance1.expects(:run).returns(:result1)
    instance2.expects(:run).returns(:result2)
    instance3.expects(:run).returns(:result3)

    orchestrator = Tachymeter::ScenarioOrchestrator.new(
      scenarios: [ scenario1, scenario2, scenario3 ]
    )

    fork_index = 2
    orchestrator.shuffle!(fork_index)

    assert_equal :result3, orchestrator.run_scenario(0)
    assert_equal :result2, orchestrator.run_scenario(1)
    assert_equal :result1, orchestrator.run_scenario(2)

    instance3_again = mock("instance3_again")
    scenario3.expects(:new).returns(instance3_again)
    instance3_again.expects(:run).returns(:result3_again)

    assert_equal :result3_again, orchestrator.run_scenario(3)
  end
end
