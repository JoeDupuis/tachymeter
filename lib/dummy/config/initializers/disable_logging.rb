# frozen_string_literal: true

error_logger = Logger.new($stderr)
error_logger.level = Logger::ERROR
error_logger.formatter = proc do |severity, datetime, progname, msg|
  "[TACHYMETER ERROR] #{msg}\n"
end

Rails.logger = error_logger
ActionController::Base.logger = error_logger
ActiveRecord::Base.logger = error_logger
