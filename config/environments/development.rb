# Configure to talk to sidekiq in its local docker container.
Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://sidekiq-cache' }
  config.logger.level = Logger::DEBUG
  Rails.logger = Sidekiq.logger
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://0.0.0.0:6379/0' }
  config.logger.level = Logger::DEBUG
  Rails.logger = Sidekiq.logger
end

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Settings specified here will take precedence over those in config/application.rb.
  config.action_mailer.default_url_options = { host: '0.0.0.0', port: 3000 }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = { address: '0.0.0.0', port: 1025 }

  # Set the active job queye adapter to Sidekiq/Redis
  # config.active_job.queue_adapter = :sidekiq
  # Alternatively, when debugging, you can set to in-line (or :async)
  # config.active_job.queue_adapter = :inline

  # Use Redis as our cache store.
  config.cache_store = :redis_cache_store, { url: ENV['RAILS_CACHE_URL'] || 'redis://0.0.0.0:6380' }

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :microsoft

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Raises error for missing translations.
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Set so we can test Devise self registration
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  # Allow traffic from localtunnel
  config.hosts << 'tguk-expenses.ngrok.io'
end
