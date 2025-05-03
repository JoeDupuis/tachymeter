# frozen_string_literal: true

module Tachymeter
  class Score
    DEFAULT_SCALE_FACTOR = 1000.0
    REFERENCE_MACHINES = { default: { throughput: 1000.0, weight: 1.0 } }
    attr_reader :max_throughput, :results, :reference_machines, :scale_factor

    def initialize(results,
                  reference_machines: REFERENCE_MACHINES,
                  scale_factor: DEFAULT_SCALE_FACTOR)
      @results = Array(results).sort_by(&:process_count)
      @reference_machines = reference_machines
      @scale_factor = scale_factor
    end

    def max_throughput
      @max_throughput ||= begin
        return 0.0 if @results.empty?
        @results.map(&:total_frequency).max
      end
    end

    def score
      return 0.0 if @results.empty?

      return max_throughput * @scale_factor if @reference_machines.empty?

      total_weight = @reference_machines.sum { |_, config| config[:weight] || 1.0 }

      weighted_score = @reference_machines.sum do |_, config|
        ref_throughput = config[:throughput]
        ref_weight = config[:weight]

        normalized_weight = ref_weight / total_weight

        (max_throughput / ref_throughput) * normalized_weight
      end

      weighted_score * @scale_factor
    end
  end
end
