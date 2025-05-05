# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "debug"
require "tachymeter"
require_relative "support/fixture_helper"


class TestCase < ActiveSupport::TestCase
  include FixtureHelper

  def reopen_stderr
    reader, writer = IO.pipe
    original_stderr = $stderr.dup
    $stderr.reopen(writer)

    begin
      yield
      $stderr.flush
      $stderr.reopen(original_stderr)
      writer.close
      reader.read
    ensure
      reader.close unless reader.closed?
      writer.close unless writer.closed?
      $stderr.reopen(original_stderr)
    end
  end
end
