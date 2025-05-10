module Tachymeter
  class Fork
    INIT_PHASE = -1

    def initialize(require_initialization = false, &block)
      @ctl_read,  @ctl_write  = IO.pipe
      @read,      @write      = IO.pipe

      @pid = fork do
        @ctl_write.close
        @read.close

        yield INIT_PHASE if require_initialization

        deadline = Marshal.load(@ctl_read)
        start_time = get_time
        end_time = start_time
        iterations  = 0
        loop do
          yield iterations
          iterations += 1
          end_time = get_time
          break if end_time >= deadline
        end

        run_time = end_time - start_time
        Marshal.dump({ request_count: iterations, time: run_time, start_time:, end_time: }, @write)
        exit 0
      end

      @ctl_read.close
      @write.close
    end

    def get_time
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    def start(deadline)
      Marshal.dump(deadline, @ctl_write)
      @ctl_write.close
    end

    def request_count = fork_output[:request_count]
    def time          = fork_output[:time]
    def wait          = fork_output.tap { @read.close; self }

    private

    def fork_output   = @fork_output ||= Marshal.load(@read)
    attr_reader :pid
  end
end
