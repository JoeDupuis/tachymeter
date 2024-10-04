# frozen_string_literal: true

require_relative "fork"
require "etc"

module Tachymeter
  class Runner
    CPU_COUNT = Etc.nprocessors
    def initialize(timeout: 1)
      @timeout = timeout
    end

    def start(&block)
      GC.disable
      create_db
      reset_db
      average_frequency = 0
      yield #preheat
      @runs = Array.new(CPU_COUNT, [])
      (1..CPU_COUNT).each do |process_count|
        new_average_frequency =  run_in_process(process_count, &block)
        percentage_diff = (new_average_frequency - average_frequency) / new_average_frequency * 100
        break if percentage_diff < -50
        average_frequency = new_average_frequency if average_frequency < new_average_frequency
        @runs[process_count] << {process_count:, average_frequency:}
        reset_db
        putc '.'
      end
      GC.enable
      @runs
    end

    private

    attr_reader :timeout

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
