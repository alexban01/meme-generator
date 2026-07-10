# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'
ENV['USERS_FILE'] = 'test_users.json'

require 'rack/test'
require 'webmock/rspec'
require_relative '../api'

WebMock.disable_net_connect!

RSpec.configure do |config|
  config.include Rack::Test::Methods

  def app
    Sinatra::Application
  end
end
