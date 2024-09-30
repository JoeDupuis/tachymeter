# frozen_string_literal: true

require "benchmark"

module Tachymeter
  class Run
    include Debug

    SUSTAINED_COUNT = 100
    BURST_COUNT = 10

    attr_reader :app, :env

    def initialize env
      @env = env
    end

    def start
      results = {}
      runs.each do |name, request_count|
        results[name] = run(request_count, env)
      end
      results
    end

    private

    def runs
      {
        sustained: SUSTAINED_COUNT,
        burst: BURST_COUNT,
      }
    end

    def run(n = 100, env)
      @app = Rails.application
      process_count = 1

      fastest_time_per_request = 99999999999
      while true
        results = Benchmark.measure do
          run_in_process(process_count) do
            n.times do
              @response = app.call(env)
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
