# frozen_string_literal: true

module Tachymeter
  class ScenarioError < StandardError
    attr_reader :status, :headers, :body

    def initialize(message, status, headers, body)
      super(message)
      @status = status
      @headers = headers
      @body = body
    end
  end

  class Scenario
    def initialize
      @env = Rack::MockRequest.env_for("/", { "HTTP_HOST" => "localhost" })
      @app = Rails.application
    end

    def run
      status, headers, body = call

      if status >= 400
        message = "HTTP Error #{status}"
        raise ScenarioError.new(message, status, headers, body)
      end

      [ status, headers, body ]
    end

    def call
      app.call(env)
    end

    private
    attr_reader :app, :env
  end
end
