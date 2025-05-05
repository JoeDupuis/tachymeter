# frozen_string_literal: true

require_relative "test_helper"

class LoggingTest < TestCase
  def setup
    @env = Rack::MockRequest.env_for("/test_error", { "HTTP_HOST" => "localhost" })
  end

  def test_error_in_stderr
    captured_stderr = reopen_stderr do
      @response = Rails.application.call(@env)
    end

    assert_equal 500, @response[0], "Expected 500 status code"
    assert_not_empty captured_stderr, "Expected error to be logged to stderr"
    assert_includes captured_stderr, "This is a test error", "Expected error message in stderr"
  end

  def test_no_log_file_growth
    log_file = Rails.root.join("log/#{Rails.env}.log")
    file_size_before = File.exist?(log_file) ? File.size(log_file) : 0

    reopen_stderr { Rails.application.call(@env) }

    file_size_after = File.exist?(log_file) ? File.size(log_file) : 0
    assert_equal file_size_before, file_size_after, "Log file should not grow when errors occur"
  end
end
