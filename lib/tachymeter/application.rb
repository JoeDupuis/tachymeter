require "dummy/config/environment"

ENV["DATABASE_URL"] ||= "sqlite3::memory:"
ENV["RAILS_ENV"] = "production"
Rails.application.initialize!
