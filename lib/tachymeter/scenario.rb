# frozen_string_literal: true

module Tachymeter
  class Scenario
    def initialize
      @env = Rack::MockRequest.env_for("/", {"HTTP_HOST" => "localhost"})
      @app = Rails.application
    end

    def run
      app.call(env)
    end

    private
    attr_reader :app, :env
  end
end
