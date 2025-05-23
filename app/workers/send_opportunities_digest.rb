class SendOpportunitiesDigest < ActiveJob::Base
  def perform
    yesterday = Time.zone.now.beginning_of_day - 1.day
    today = Time.zone.now.end_of_day

    results = SubscriptionNotification.joins(:subscription).where(
      'subscription_notifications.created_at >= ? and subscription_notifications.created_at <= ? and sent=false and subscriptions.unsubscribed_at is null', yesterday, today
    ).group(:user_id).count(:opportunity_id)
    # user_id -> count_opportunity_ids
    # => {"1feb333d-ff17-49f8-9caa-2053bb0b25fa"=>4, "6083766f-e113-46e7-b4df-7c63c50d5b89"=>2}

    # go through each user
    results.each do |user_id, opp_count|
      struct = {}
      struct[:subscriptions] = {}

      struct[:count] = opp_count

      # find all subscriptions for this user, along with count of opps for this day
      subscriptions = SubscriptionNotification.joins(:subscription).where(
        'subscription_notifications.created_at >= ? and subscription_notifications.created_at <= ? and subscriptions.user_id = ? and sent=false and subscriptions.unsubscribed_at is null', yesterday, today, user_id
      ).group(:subscription_id).count(:opportunity_id)

      subscriptions.each do |subscription_id, subscription_count|
        # the one random opportunity that we are going to use for this subscription. order by source to fetch DBT opps first
        sample_opportunity = SubscriptionNotification.where(subscription_id: subscription_id).includes(:subscription).joins(:opportunity).where(sent: false).where(
          'subscription_notifications.created_at >= ? and subscription_notifications.created_at <= ?', yesterday, today
        ).select(:subscription_id).select(:opportunity_id).order('opportunities.source').first.opportunity
        subscription = Subscription.find(subscription_id)
        struct[:subscriptions][subscription_id] = {
          subscription: subscription,
          count: subscription_count,
          opportunity: sample_opportunity
        }
      end

      OpportunityMailer.send_opportunity(User.find(user_id), struct).deliver_later!

      # update subscription notifications to sent=true
      subscriptions.each_key do |sub|
        sub_nots = SubscriptionNotification.where(subscription_id: sub).where(sent: false).where(
          'subscription_notifications.created_at >= ? and subscription_notifications.created_at <= ?', yesterday, today
        )
        sub_nots.update_all(sent: true) unless Rails.env.development?
      end
    end
  end
end
