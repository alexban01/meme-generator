# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'
ENV['DB_PATH'] = ':memory:'

require 'rack/test'
require 'webmock/rspec'
require_relative '../api'

WebMock.disable_net_connect!

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.before { DB.clear }

  def app
    Sinatra::Application
  end
end
