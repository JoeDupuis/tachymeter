# frozen_string_literal: true

require "benchmark"

module Tachymeter
  class Run
    def start(n = 300, &block)
      process_count = 1

      average_frequency = 0
      yield #preheat
      while true
        results = Benchmark.measure do
          run_in_process(process_count) { n.times(&block) }
        end
        new_frequency =  n * process_count / results.real
        break unless  average_frequency < new_frequency
        average_frequency = new_frequency
        process_count += 1
      end
      reset_db
      [process_count, average_frequency * process_count]
    end

    def reset_db
      ActiveRecord::Tasks::DatabaseTasks.load_schema_current(ActiveRecord.schema_format, ENV["SCHEMA"])
      ActiveRecord::Tasks::DatabaseTasks.load_seed
    end

    def run_in_process(process_count = 1, &block)
      process_count.times { fork(&block) }
      Process.waitall
    end
  end
end
