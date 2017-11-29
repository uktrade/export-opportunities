Raven.configure do |config|
  config.dsn = Figaro.env.SENTRY_RAVEN_DSN
  config.environments = %w[staging production]
end
