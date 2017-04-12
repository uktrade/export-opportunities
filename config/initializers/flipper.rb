require 'redis'
require 'flipper/adapters/redis'

# https://github.com/jnunemaker/flipper/blob/master/docs/Optimization.md
module ExportOpportunities
  def self.flipper
    @flipper ||= begin
                   redis = Redis.new(url: Figaro.env.redis_url!)
                   namespaced_redis = Redis::Namespace.new(:flipper, redis: redis)
                   adapter = Flipper::Adapters::Redis.new(namespaced_redis)
                   Flipper.new(adapter)
                 end
  end
end
