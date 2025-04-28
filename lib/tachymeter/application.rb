require "dummy/config/environment"


module Tachymeter
  class Application
    def initialize
      ENV["DATABASE_URL"] = "sqlite3::memory:"
      ENV["RAILS_ENV"] = "production"
      Rails.application.initialize!
    end
  end
end
