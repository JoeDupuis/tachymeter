module Tachymeter
  class ResultSet < Struct.new(:process_count, :average_frequency, :run_id)
    def total_frequency
      @total_frequency ||= process_count * average_frequency
    end

    def to_h = { process_count:, average_frequency:, run_id: }

    def self.from_h(h)
      new(h[:process_count], h[:average_frequency], h[:run_id])
    end
  end
end
