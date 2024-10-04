# frozen_string_literal: true

require_relative "fork"

module Tachymeter
  class Runner
    def initialize(timeout: 3)
      @timeout = timeout
    end

    def start(&block)
      GC.disable
      create_db
      reset_db
      process_count = 1
      average_frequency = 0
      yield #preheat
      while true
        new_average_frequency =  run_in_process(process_count, &block)
        percentage = (new_average_frequency - average_frequency) / new_average_frequency * 100

        break if percentage < -20
        average_frequency = new_average_frequency if average_frequency < new_average_frequency

        process_count += 1
        reset_db
      end
      process_count -= 1
      GC.enable
      [process_count, average_frequency * process_count]
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
      forks.each(&:start)
      forks.sum {|fork| fork.request_count / fork.time} / process_count
    ensure
      Process.waitall
    end
  end
end
