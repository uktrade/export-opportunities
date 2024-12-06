Sentry.init do |config|
  config.dsn = Figaro.env.SENTRY_RAVEN_DSN
  config.enabled_environments = %w[staging production]
end
