require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CatchchatServer
  class Application < Rails::Application
    config.autoload_paths += %W(#{config.root}/lib #{config.root}/app/services #{config.root}/app/jobs)
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Beijing'
    config.active_record.default_timezone = :local

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.enforce_available_locales = false
    config.i18n.available_locales = [:'zh-CN', :en]
    config.i18n.default_locale = :"zh-CN"

    config.i18n.fallbacks = true

    config.i18n.fallbacks = [:en]

    config.generators do |g|
      g.assets false
    end

    config.middleware.use Rack::Attack

    config.cache_store = :redis_store, Settings.redis.cache.to_h.symbolize_keys.merge(expires_in: 1.day)
  end
end
