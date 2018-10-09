require 'set'

class SendOpportunitiesDigest
  include Sidekiq::Worker

  def perform
    yesterday_date = (Time.zone.now - 1.day).strftime('%Y-%m-%d')
    today_date = Time.zone.now.strftime('%Y-%m-%d')

    results = SubscriptionNotification.joins(:subscription).where('subscription_notifications.created_at >= ? and subscription_notifications.created_at <= ? and sent=false', yesterday_date, '2018-10-02').group(:user_id).count(:opportunity_id)
    # user_id -> count_opportunity_ids
    # => {"1feb333d-ff17-49f8-9caa-2053bb0b25fa"=>4, "6083766f-e113-46e7-b4df-7c63c50d5b89"=>2}

    struct = {}
    struct[:subscriptions] = {}

    # go through each user
    results.each do |user_id, opp_count|
      struct[:count] = opp_count

      # find all subscriptions for this user, along with count of opps for this day
      subscriptions = SubscriptionNotification.joins(:subscription).where('subscription_notifications.created_at >= ? and subscription_notifications.created_at <= ? and subscriptions.user_id = ? and sent=false', yesterday_date, today_date, user_id).group(:subscription_id).count(:opportunity_id)

      subscriptions.each do |subscription_id, subscription_count|
        # the one random opportunity that we are going to use for this subscription
        sample_opportunity = SubscriptionNotification.where(subscription_id: subscription_id).where(sent: false).where('subscription_notifications.created_at >= ? and subscription_notifications.created_at < ?', yesterday_date, today_date).select(:opportunity_id).sample(1).first.opportunity
        subscription = Subscription.find(subscription_id)
        struct[:subscriptions][subscription_id] = {
          subscription: subscription,
          target_url: url_from_subscription(subscription),
          count: subscription_count,
          opportunity: sample_opportunity,
        }
      end

      OpportunityMailer.send_opportunity(User.find(user_id), struct).deliver_later!

      # update subscription notifications to sent=true
      subscriptions.each do |sub, _count|
        subscription = Subscription.find(sub)
        sub_nots = SubscriptionNotification.where(subscription_id: subscription).where(sent: false).where('subscription_notifications.created_at >= ? and subscription_notifications.created_at < ?', yesterday_date, today_date)
        sub_nots.update_all(sent: true) unless Rails.env.development?
      end
    end
  end

  def url_from_subscription(subscription)
    if subscription.search_term && subscription.countries
      target_url = "/opportunities?s=#{subscription.search_term}"
      subscription.countries.each do |country|
        target_url += "&countries%5B%5D=#{country.slug}"
      end
    elsif subscription.search_term
      target_url = "/opportunities?s=#{subscription.search_term}"
    elsif subscription.countries
      target_url = '/opportunities?s=&sort_column_name=response_due_on'
      subscription.countries.each do |country|
        target_url += "&countries%5B%5D=#{country.slug}"
      end
    else
      target_url = '/opportunities'
    end
    target_url
  end
end
