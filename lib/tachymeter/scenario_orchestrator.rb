# frozen_string_literal: true

require_relative "scenarios/hello_world_scenario"

module Tachymeter
  class ScenarioOrchestrator
    DEFAULT_SCENARIOS = [ Scenarios::HelloWorldScenario ]
    ANSWER_TO_LIFE = 42

    def initialize(seed: nil, scenarios: nil)
      @scenarios = scenarios || DEFAULT_SCENARIOS
      @seed = seed || ANSWER_TO_LIFE
    end

    def shuffle!(fork_index)
      fork_seed = @seed + fork_index
      fork_rng = Random.new(fork_seed)
      @scenarios.shuffle!(random: fork_rng)
    end

    def run_scenario(iteration)
      scenario_class = @scenarios[iteration % @scenarios.size]
      scenario_class.new.run
    end
  end
end
