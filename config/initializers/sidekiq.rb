require 'sidekiq'
require 'sidekiq/web'
require 'sidekiq/cron/web'

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('redis_url') }
  schedule_file = 'config/sidekiq_schedule.yml'

  if File.exist?(schedule_file) && Sidekiq.server?
    Sidekiq::Cron::Job.load_from_hash! YAML.load_file(schedule_file)
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('redis_url') }
end

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == [ENV.fetch('sidekiq_username'), ENV.fetch('sidekiq_password')]
end
