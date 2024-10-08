require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module App
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    config.generators do |g|
      g.helper false
      g.skip_routes true
      g.test_framework false
    end

    # 97-タイムゾーンを設定する
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local
    # 日本語化
    config.i18n.default_locale = :ja
    # sidekiqをactivejobで利用する
    config.active_job.queue_adapter = :sidekiq

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = 'Central Time (US & Canada)'
    # config.eager_load_paths << Rails.root.join('extras')
  end
end
