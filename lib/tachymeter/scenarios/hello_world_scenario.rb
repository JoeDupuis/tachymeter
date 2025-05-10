# frozen_string_literal: true

module Tachymeter
  module Scenarios
    class HelloWorldScenario < Scenario
      def initialize
        super
      end

      def run
        get("/")
      end
    end
  end
end
