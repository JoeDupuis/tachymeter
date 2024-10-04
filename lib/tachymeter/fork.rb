module Tachymeter
  class Fork
    def initialize(timeout: 3)
      @read, @write = IO.pipe

      @pid = fork do
        read.close
        wait_for_usr1
        start_time = Time.now

        i = 0
        end_time = nil
        loop do
          yield
          i += 1
          break if ((end_time = Time.now) - start_time) > timeout
        end

        Marshal.dump({request_count: i, time: end_time - start_time}, write)
        write.close
        exit 0
      end
      write.close
    end

    def start
      Process.kill("USR1", pid)
    end

    def request_count
      fork_output[:request_count]
    end

    def time
      fork_output[:time]
    end

    def wait
      fork_output
      self
    end

    private

    def fork_output
      @fork_output ||= Marshal.load(read)
    end

    attr_reader :read, :write, :pid

    def wait_for_usr1
      thread = Thread.new do
        current_thread = Thread.current
        Signal.trap("USR1") do
          current_thread.kill
        end
        sleep
      end
      thread.join
    end
  end
end
