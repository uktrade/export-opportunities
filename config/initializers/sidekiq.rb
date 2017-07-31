Sidekiq.configure_server do |config|
  if Rails.env.development?
    config.redis = { url: Figaro.env.redis_url! }
    schedule_file = 'config/sidekiq_schedule.yml'

    if File.exist?(schedule_file) && Sidekiq.server?
      Sidekiq::Cron::Job.load_from_hash! YAML.load_file(schedule_file)
    end
  else
    config.redis = {
        master_name: 'redis://' + Figaro.env.redis_sentinel_host!,
        sentinels: [
            'sentinel://' + Figaro.env.redis_sentinel_host! + ':26379',
        ],
        failover_reconnect_timeout: 20,
        password: Figaro.env.redis_sentinel_password!,
    }
  end
end

Sidekiq.configure_client do |config|
  config.redis = if Rails.env.development?
                   { url: Figaro.env.redis_url! }
                 else
                   {
                       master_name: 'redis://' + Figaro.env.redis_sentinel_host!,
                       sentinels: [
                           'sentinel://' + Figaro.env.redis_sentinel_host! + ':26379',
                       ],
                       failover_reconnect_timeout: 20,
                       password: Figaro.env.redis_sentinel_password!,
                   }
                 end
end