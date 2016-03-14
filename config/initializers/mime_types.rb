# Be sure to restart your server when you modify this file.

Mime::Type.register "application/vnd.api+json", :jsonapi

middlewares = ReduxWorkshopRailsWay::Application.config.middleware
middlewares.swap(ActionDispatch::ParamsParser, ActionDispatch::ParamsParser, {
  Mime::Type.lookup('application/vnd.api+json') => lambda do |body|
    ActiveSupport::JSON.decode(body)
  end
})


# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
