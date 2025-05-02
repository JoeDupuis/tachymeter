# frozen_string_literal: true

require "json"
require "pathname"

module Tachymeter
  class JsonExport
    DEFAULT_OUTPUT = "results.json".freeze

    def self.write(runs, out_path = DEFAULT_OUTPUT)
      run_data = {}

      runs.each do |run|
        run_data[run.process_count] = {
          process_count: run.process_count,
          rps_avg: run.average_frequency,
          rps_sum: run.total_frequency
        }
      end

      data = { runs: run_data }

      Pathname(out_path).write(JSON.pretty_generate(data))
      out_path
    end
  end
end
