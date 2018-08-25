Raven.configure do |config|
  config.dsn = ENV['SENTRY_RAVEN_DSN']
  config.environments = %w[staging production]
end
