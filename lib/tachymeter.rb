# frozen_string_literal: true

require_relative "tachymeter/version"
require_relative "tachymeter/debug"
require_relative "tachymeter/run"
require "dummy/config/environment"

module Tachymeter
  class Error < StandardError; end
end
