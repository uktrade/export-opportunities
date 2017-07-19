# SENTINELS = [{host: "exportopps-redis.gds-dev.uktrade.io", port: 26379}]
# opts = { password: 'l2t5eFUr1d4qr8l2ns83JTpff9p0V5eF22WzMe3OiBnog1yvvMit11X6xF95mTOH' }

redis_conn = proc {
  Redis.new url: 'redis://exportopps-redis.gds-dev.uktrade.io', sentinels: SENTINELS, role: :master, opts: opts
}

Sidekiq.configure_server do |config|
  #config.redis = ConnectionPool.new(size: 5, &redis_conn)
  config.redis = {
      master_name: 'redis://exportopps-redis.gds-dev.uktrade.io',
      sentinels: [
          'sentinel://exportopps-redis.gds-dev.uktrade.io:26379',
      ],
      failover_reconnect_timeout: 20,
      password: 'l2t5eFUr1d4qr8l2ns83JTpff9p0V5eF22WzMe3OiBnog1yvvMit11X6xF95mTOH',
  }
end

Sidekiq.configure_client do |config|
  # config.redis = { url: Figaro.env.redis_url! }
  config.redis = {
      master_name: 'redis://exportopps-redis.gds-dev.uktrade.io',
      sentinels: [
          'sentinel://exportopps-redis.gds-dev.uktrade.io:26379',
      ],
      failover_reconnect_timeout: 20,
      password: 'l2t5eFUr1d4qr8l2ns83JTpff9p0V5eF22WzMe3OiBnog1yvvMit11X6xF95mTOH',
  }
end
