# frozen_string_literal: true

require_relative "test_helper"

class ScenarioTest < TestCase
  setup do
    Tachymeter.application.configure_database
    Tachymeter.application.create_db
    Tachymeter.application.load_schema
    Tachymeter.application.seed
  end

  def test_error_endpoint_raises_scenario_error
    scenario = Tachymeter::Scenarios::CrashScenario.new

    error = assert_raises(Tachymeter::ScenarioError) do
      reopen_stderr { scenario.run }
    end

    assert_equal 500, error.status
    assert_match /HTTP Error 500/, error.message
  end

  def test_normal_endpoint_succeeds
    scenario = Tachymeter::Scenarios::HelloWorldScenario.new

    assert_nothing_raised do
      scenario.run
    end
  end
end
