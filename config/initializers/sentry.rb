Sentry.init do |config|
  config.dsn = Figaro.env.SENTRY_RAVEN_DSN
  config.enabled_environments = %w[dev staging uat prod production]
  config.traces_sample_rate = 1.0
end
