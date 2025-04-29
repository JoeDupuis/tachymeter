# frozen_string_literal: true

require "optparse"
require "tachymeter"
require "etc"

module Tachymeter
  class CLI
    DEFAULT_TIMEOUT = 5
    LOW_REF_RPS  = 700      # placeholder calibration numbers
    HIGH_REF_RPS = 8_000    # placeholder calibration numbers

    def initialize(argv = ARGV)
      @options = { timeout: DEFAULT_TIMEOUT }
      parse_options!(argv)
    end

    # Entrypoint for the executable
    def run
      @options[:runs] ||= (1..Etc.nprocessors).to_a
      scenario = Tachymeter::Scenario.new
      runner   = Tachymeter::Runner.new(
        timeout:  @options[:timeout],
        full_run: @options[:full_run],
        runs:     @options[:runs]
      )
      results = runner.start { scenario.run }
      if results.empty?
        warn "No benchmark results produced—nothing to score."
        exit(1)
      end

      max_set   = results.max_by(&:total_frequency)
      max_rps   = max_set.total_frequency
      max_avg   = max_set.average_frequency
      mean_avg  = results.sum(&:average_frequency) / results.size.to_f

      score_obj = Tachymeter::Score.new(results)
      puts "Score: #{score_obj.score.round}"
      puts "Max throughput: %.1f req/s @ %d processes" % [max_rps, max_set.process_count]
      puts "Max RPS / process: %.1f" % max_avg
      puts "Mean RPS / process across curve: %.1f" % mean_avg
    end

    private

    def parse_options!(argv)
      OptionParser.new do |opts|
        opts.banner = "Usage: tachymeter [options]"

        opts.on("-t", "--timeout N", Integer, "Timeout seconds (default #{DEFAULT_TIMEOUT})") do |v|
          @options[:timeout] = v
        end

        opts.on("-p", "--procs x,y,z", Array, "Comma‑separated process counts (e.g. 1,2,4,8)") do |list|
          @options[:runs] = list.map(&:to_i)
        end

        opts.on("-f", "--full", "Full run (ignore 50% drop‑off rule)") do
          @options[:full_run] = true
        end

        opts.on("-h", "--help", "Print this help") do
          puts opts
          exit
        end
      end.parse!(argv)
    end
  end
end
