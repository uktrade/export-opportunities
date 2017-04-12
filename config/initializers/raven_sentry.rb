Raven.configure do |config|
  config.dsn = Figaro.env.SENTRY_RAVEN_DSN
  config.secret_key = Figaro.env.SENTRY_RAVEN_SECRET_KEY
  config.environments = %w(staging production)
end
