# frozen_string_literal: true

require 'tachymeter'

module Tachymeter
  class CLI
    def initialize
      @scenario = Tachymeter::Scenario.new
    end

    def run
      results = 5.times.map do
        Tachymeter::Runner.new(timeout: 5, runs: Tachymeter::Runner::CPU_COUNT).start { scenario.run }
      end

      results.map(&:sole).sort_by!(&:average_frequency)
      max, min = results.last.sole.total_frequency, results.first.sole.total_frequency
      delta = (max - min)

      pp results.third.sole.total_frequency, delta
    end

    private

    attr_reader :scenario
  end
end
