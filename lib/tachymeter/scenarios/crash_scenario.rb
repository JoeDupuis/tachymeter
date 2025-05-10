# frozen_string_literal: true

module Tachymeter
  module Scenarios
    class CrashScenario < Scenario
      def initialize
        super
      end

      def run
        get("/test_error")
      end
    end
  end
end
