# frozen_string_literal: true

require_relative "tachymeter/version"
require_relative "tachymeter/debug"
require_relative "tachymeter/runner"
require "dummy/config/environment"

module Tachymeter
  class Error < StandardError; end
end

module ActiveRecord::Tasks::DatabaseTasks
  def verbose?
    ENV["VERBOSE"] == "true"
  end
end
