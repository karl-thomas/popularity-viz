require_relative 'boot'
require 'rspotify'
require 'rails/all'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PopularityViz
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1
  

    config.action_dispatch.default_headers = {
      'Access-Control-Allow-Origin' => 'http://karl-thomas.com',
      'Access-Control-Allow-Methods' => 'GET, OPTIONS',
      'Access-Control-Allow-Headers' => 'Authorization'    
    }
# 'Access-Control-Request-Method' => %w{GET POST OPTIONS}.join(",")
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
