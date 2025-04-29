# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "debug"
require "tachymeter"
require_relative "support/fixture_helper"


class TestCase < ActiveSupport::TestCase
  include FixtureHelper
end
