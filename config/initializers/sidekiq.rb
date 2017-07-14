Sidekiq.configure_server do |config|
  config.redis = { url: Figaro.env.redis_url! }
end

Sidekiq.configure_client do |config|
  config.redis = { url: Figaro.env.redis_url! }
end

Sidekiq.configure_server do |config|
  schedule_file = "config/sidekiq_schedule.yml"

  if File.exists?(schedule_file) && Sidekiq.server?
    Sidekiq::Cron::Job.load_from_hash! YAML.load_file(schedule_file)
  end
end