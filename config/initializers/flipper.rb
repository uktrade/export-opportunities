require 'redis'
require 'flipper/adapters/redis'

# https://github.com/jnunemaker/flipper/blob/master/docs/Optimization.md
module ExportOpportunities
  def self.flipper
    @flipper ||= begin
                   redis = Redis.new(url: Figaro.env.REDIS_URL!)
                   namespaced_redis = Redis::Namespace.new(:flipper, redis: redis)
                   adapter = Flipper::Adapters::Redis.new(namespaced_redis)
                   Flipper.new(adapter)
                 end
    @flipper.enable(:activity_stream) if Figaro.env.ACTIVITY_STREAM_ENABLED == 'true'
    @flipper
  end
end
