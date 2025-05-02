# frozen_string_literal: true

require "erb"
require "pathname"
require "json"

module Tachymeter
  class HtmlExport
    DEFAULT_OUTPUT   = "results.html".freeze
    DEFAULT_TEMPLATE = File.expand_path("templates/results.html.erb", __dir__).freeze

    def self.write(runs, out_path = DEFAULT_OUTPUT, template: DEFAULT_TEMPLATE)
      labels   = runs.map(&:process_count)
      rps_avg  = runs.map(&:average_frequency)
      rps_sum  = runs.map(&:total_frequency)

      html = ERB.new(File.read(template), trim_mode: "-")
        .result_with_hash(
          labels: labels,
          rps_avg: rps_avg,
          rps_sum: rps_sum
        )

      Pathname(out_path).write(html)
      out_path
    end
  end
end
