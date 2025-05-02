# frozen_string_literal: true

require_relative "tachymeter/version"
require_relative "tachymeter/debug"
require_relative "tachymeter/runner"
require_relative "tachymeter/scenario"
require_relative "tachymeter/application"
require_relative "tachymeter/html_export"
require_relative "tachymeter/json_export"
require_relative "tachymeter/cli"
require "tachymeter/score"

module Tachymeter
  class Error < StandardError; end
end

module ActiveRecord::Tasks::DatabaseTasks
  def verbose?
    ENV["VERBOSE"] == "true"
  end
end
