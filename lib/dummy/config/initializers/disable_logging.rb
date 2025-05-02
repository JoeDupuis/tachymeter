# frozen_string_literal: true

if Rails.env.production? && !ActiveModel::Type::Boolean.new.cast(ENV["TACHYMETER_DEBUG"])
  null_logger = Logger.new(IO::NULL)
  null_logger.level = Logger::FATAL

  Rails.logger = null_logger
  ActiveRecord::Base.logger = null_logger
  ActionController::Base.logger = null_logger
  ActionMailer::Base.logger = null_logger
  ActiveJob::Base.logger = null_logger
  ActionView::Base.logger = null_logger

  Rails.application.config.paths["log"] = IO::NULL
end
