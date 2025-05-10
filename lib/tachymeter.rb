# frozen_string_literal: true

require_relative "tachymeter/version"
require_relative "tachymeter/debug"
require_relative "tachymeter/scenario"
Dir[File.join(__dir__, "tachymeter/scenarios", "*.rb")].each { |file| require file }
require_relative "tachymeter/scenario_orchestrator"
require_relative "tachymeter/runner"
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
    return false if Rails.env.production? && !ActiveModel::Type::Boolean.new.cast(ENV["TACHYMETER_DEBUG"])
    ENV["VERBOSE"] == "true"
  end
end
