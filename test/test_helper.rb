# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "debug"
require "tachymeter"
require "minitest/autorun"
require_relative "support/fixture_helper"


class TestCase < Minitest::Test
  include FixtureHelper
end
