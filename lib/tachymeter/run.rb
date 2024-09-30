# frozen_string_literal: true

require "benchmark"

module Tachymeter
  class Run
    def start(n = 300)
      process_count = 1

      fastest_time_per_request = 99999999999
      yield #pre heat
      while true
        results = Benchmark.measure do
          run_in_process(process_count) do
            n.times do
              yield
            end
          end
        end
        time_per_request = results.real / (n * process_count)
        break if fastest_time_per_request < time_per_request
        fastest_time_per_request = time_per_request
        process_count += 1
        puts "."
      end
      [process_count, fastest_time_per_request]
    end

    def run_in_process process_count = 1
      process_count.times do
        fork do
          yield
        end
      end
      Process.waitall
    end
  end
end
