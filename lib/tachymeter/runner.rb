# frozen_string_literal: true

require_relative "fork"
require_relative "result"
require "etc"

module Tachymeter
  class Runner
    CPU_COUNT = Etc.nprocessors
    def initialize(timeout: 1, dropoff: 50, full_run: false, runs: (1..CPU_COUNT))
      @timeout = timeout
      @dropoff = dropoff
      @full_run = full_run
      @run_id = SecureRandom.uuid
      @runs = Array(runs)
    end

    def start(&block)
      GC.disable
      create_db
      reset_db
      average_frequency = 0
      yield #preheat
      @results = []
      runs.each do |process_count|
        new_average_frequency =  run_in_process(process_count, &block)
        percentage_diff = (new_average_frequency - average_frequency) / new_average_frequency * 100
        break if !full_run && percentage_diff < -dropoff
        average_frequency = new_average_frequency if average_frequency < new_average_frequency
        @results << Result.new(process_count:, average_frequency: new_average_frequency, run_id:)
        reset_db
        putc '.'
      end
      GC.enable
      @results
    end

    private

    attr_reader :timeout, :dropoff, :full_run, :run_id, :runs

    def create_db
      ActiveRecord::Tasks::DatabaseTasks.create_all
    end

    def reset_db
      ActiveRecord::Tasks::DatabaseTasks.load_schema_current(ActiveRecord.schema_format, ENV["SCHEMA"])
      ActiveRecord::Tasks::DatabaseTasks.load_seed
    end

    def run_in_process(process_count = 1, &block)
      forks = process_count.times
        .map { Fork.new(timeout:, &block) }
      sleep 1 #wait for all forks to be ready
      forks.each(&:start).each(&:wait)
      forks.sum {|fork| fork.request_count / fork.time} / process_count
    ensure
      Process.waitall
    end
  end
end
