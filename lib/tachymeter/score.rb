# frozen_string_literal: true

module Tachymeter
  class Score
    LOW_REF_AUC  = 7_000.0
    HIGH_REF_AUC = 80_000.0

    def initialize(results,
                   low_ref:  LOW_REF_AUC,
                   high_ref: HIGH_REF_AUC)
      @results  = Array(results).sort_by(&:process_count)
      @low_ref  = low_ref
      @high_ref = high_ref
    end

    def area_under_curve
      return 0.0 if @results.size < 2

      @results.each_cons(2).sum do |a, b|
        dx = b.process_count - a.process_count
        (a.total_frequency + b.total_frequency) * dx / 2.0
      end
    end

    def score
      auc = area_under_curve
      return 1_000  if auc <= @low_ref
      return 10_000 if auc >= @high_ref

      span = @high_ref - @low_ref
      1_000 + (auc - @low_ref) * 9_000.0 / span
    end
  end
end
