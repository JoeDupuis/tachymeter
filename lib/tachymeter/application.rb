require "dummy/config/environment"


module Tachymeter
  class Application
    def initialize database_url: "sqlite3::memory:"
      ENV["DATABASE_URL"] = database_url
      ENV["RAILS_ENV"] = "production"
      Rails.application.initialize!
    end
  end
end
