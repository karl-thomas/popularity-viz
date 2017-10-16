require_relative 'boot'
require 'rspotify'
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PopularityViz
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1
    
    config.action_dispatch.default_headers = {
    'Access-Control-Allow-Origin' => 'http://karl-thomas.com',
    'Access-Control-Request-Method' => 'GET'
      }
# 'Access-Control-Request-Method' => %w{GET POST OPTIONS}.join(",")
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
