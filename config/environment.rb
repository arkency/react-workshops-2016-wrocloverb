# Load the Rails application.
require File.expand_path('../application', __FILE__)

Mime::Type.register "application/vnd.api+json", :jsonapi

# Initialize the Rails application.
Rails.application.initialize!
