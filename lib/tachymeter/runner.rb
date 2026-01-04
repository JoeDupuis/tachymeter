# frozen_string_literal: true

require_relative "fork"
require_relative "result"
require "etc"
require "securerandom"

module Tachymeter
  class Runner
    CPU_COUNT = Etc.nprocessors

    def initialize(timeout: 1, full_run: false, runs: nil, init_forks: false)
      @timeout = timeout
      @full_run = full_run
      @run_id = SecureRandom.uuid
      @runs = Array(runs || (full_run ? (1..CPU_COUNT) : [ CPU_COUNT ]))
      @init_forks = init_forks
    end

    def start(&block)
      raise ArgumentError, "Block is required" unless block_given?

      create_db
      reset_db
      yield 0, 0 # preheat
      @results = []
      runs.each do |process_count|
        average_frequency = run_in_process(process_count, &block)
        @results << Result.new(process_count:, average_frequency:, run_id:)
        reset_db
        putc "."
      end

      @results
    end

    private

    attr_reader :timeout, :full_run, :run_id, :runs, :init_forks

    def create_db
      ActiveRecord::Tasks::DatabaseTasks.create_all
    end

    def reset_db
      ActiveRecord::Tasks::DatabaseTasks.load_schema_current(ActiveRecord.schema_format, ENV["SCHEMA"])
      ActiveRecord::Tasks::DatabaseTasks.load_seed
    end

    def run_in_process(process_count, &block)
      forks = process_count.times.map do |fork_index|
        Fork.new(init_forks) { |iteration| yield(fork_index, iteration) }
      end

      deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout

      forks.each { |f| f.start(deadline) }
      forks.each(&:wait)

      total_frequency = forks.sum { |f| f.time.positive? ? f.request_count / f.time : 0 }
      process_count.positive? ? total_frequency / process_count : 0
    ensure
      Process.waitall
    end
  end
end
