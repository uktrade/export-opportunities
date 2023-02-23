require 'set'

class OpportunitiesCounters < ActiveJob::Base
  sidekiq_options retry: false

  def perform
    redis = Redis.new(url: Figaro.env.REDIS_URL!)
    today = Time.zone.now
    tomorrow = today + 3.days
    yesterday = today - 1.day
    all_opps = Opportunity.where(status: :publish).where('response_due_on >= ?', today.strftime('%Y-%m-%d')).count
    expiring_soon_opps = Opportunity.where(status: :publish).where('response_due_on >= ?', today.strftime('%Y-%m-%d')).where('response_due_on <= ?', tomorrow.strftime('%Y-%m-%d')).count
    published_recently_opps = Opportunity.where(status: :publish).where('created_at >= ?', yesterday.strftime('%Y-%m-%d')).count

    redis.set(:opps_counters_last_modified, today)
    redis.set(:opps_counters_total, all_opps.to_i)
    redis.set(:opps_counters_expiring_soon, expiring_soon_opps.to_i)
    redis.set(:opps_counters_published_recently, published_recently_opps.to_i)
  end
end
