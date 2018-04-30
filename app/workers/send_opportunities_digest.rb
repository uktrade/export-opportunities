require 'set'

class SendOpportunitiesDigest
  include Sidekiq::Worker

  def perform
    today_date = Time.zone.now.strftime('%Y-%m-%d')
    tomorrow_date = (Time.zone.now + 1.day).strftime('%Y-%m-%d')

    results = SubscriptionNotification.joins(:subscription).where('subscription_notifications.created_at >= ? and subscription_notifications.created_at < ?', today_date, tomorrow_date)

    user_with_notification_opportunity_ids = {}
    results.each do |result|
      if result.subscription.user_id
        user_with_notification_opportunity_ids[result.subscription.user_id] ||= Set.new
        user_with_notification_opportunity_ids[result.subscription.user_id].add(result.opportunity_id)
      end
    end

    user_with_notification_opportunity_ids.each do |user_id, opportunity_ids|
      opportunities = []
      opportunity_ids.each do |opportunity_id|
        opportunities.push(Opportunity.find(opportunity_id))
      end
      OpportunityMailer.send_opportunity(User.find(user_id), opportunities.first(5)).deliver_later!
    end

    # once we've sent notifications, update sent to true to avoid sending the same notifications again in the future
    results.update_all(sent: true) unless Rails.env.development?
  end
end
