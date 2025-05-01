ENV["DATABASE_URL"] ||= "sqlite3::memory:"
ENV["RAILS_ENV"] = "production"
require "dummy/config/environment"
Rails.application.initialize!
