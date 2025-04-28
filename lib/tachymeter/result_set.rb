module Tachymeter
  class ResultSet < Struct.new(:process_count, :average_frequency, :run_id)
    def total_frequency
      @total_frequency ||= process_count * average_frequency
    end
  end
end
