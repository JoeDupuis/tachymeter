# frozen_string_literal: true

require "action_controller/railtie"
require "action_dispatch/testing/integration"

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
    HTTP_METHODS = [ :get, :post, :put, :patch, :delete, :head, :options ]

    def initialize
      @session = ActionDispatch::Integration::Session.new(Rails.application)
    end

    def run
      get("/")
    end

    HTTP_METHODS.each do |method_name|
      define_method(method_name) do |path, **args|
        @session.public_send(method_name, path, **args)
        check_response(@session.response)
        [ @session.status, @session.headers, @session.response.body ]
      end
    end

    def follow_redirect!
      @session.follow_redirect!
      check_response(@session.response)
      [ @session.status, @session.headers, @session.response.body ]
    end

    def parsed_body
      @session.response.parsed_body
    end

    def response
      @session.response
    end

    def cookies
      @session.cookies
    end

    def session
      @session
    end

    private

    def check_response(response)
      if response.status >= 400
        message = "HTTP Error #{response.status}"
        raise ScenarioError.new(message, response.status, response.headers, response.body)
      end

      response
    end
  end
end
