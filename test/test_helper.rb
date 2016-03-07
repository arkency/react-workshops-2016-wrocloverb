ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'


class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  require_relative './helpers/test_api_client'
  require_relative './helpers/application_api_test_set'
  # Add more helper methods to be used by all tests here...

  def json(hash)
    MultiJson.load(hash.to_json)
  end
end
