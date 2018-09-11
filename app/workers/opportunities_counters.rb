require 'set'

class OpportunitiesCounters
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform
    redis = Redis.new(url: Figaro.env.redis_url!)
    today = Time.zone.now
    tomorrow = today + 3.days
    yesterday = today - 1.day
    all_opps = Opportunity.where(status: :publish).where('response_due_on > ?', today).count
    expiring_soon_opps = Opportunity.where(status: :publish).where('response_due_on > ?', today).where('response_due_on < ?', tomorrow.strftime('%Y-%m-%d')).count
    published_recently_opps = Opportunity.where(status: :publish).where('created_at > ?', yesterday).count

    redis.set(:opps_counters_last_modified, today)
    redis.set(:opps_counters_total, all_opps.to_i)
    redis.set(:opps_counters_expiring_soon, expiring_soon_opps.to_i)
    redis.set(:opps_counters_published_recently, published_recently_opps.to_i)
  end
end
