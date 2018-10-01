require 'set'

class SendOpportunitiesDigest
  include Sidekiq::Worker

  def perform
    yesterday_date = (Time.zone.now - 1.day).strftime('%Y-%m-%d')
    today_date = Time.zone.now.strftime('%Y-%m-%d')

    # results = SubscriptionNotification.joins(:subscription).where('subscription_notifications.created_at >= ? and subscription_notifications.created_at < ? and sent=false', yesterday_date, today_date)

    results = SubscriptionNotification.joins(:subscription).where('subscription_notifications.created_at >= ? and subscription_notifications.created_at <= ? and sent=false', yesterday_date, '2018-10-02').group(:user_id).count(:opportunity_id)
    # user_id -> count_opportunity_ids
    # => {"1feb333d-ff17-49f8-9baa-2053bb0b25fa"=>4, "6083766f-e112-46e7-b4df-7c63c50d5b89"=>2}

    #  {["1feb333d-ff17-49f8-9baa-2053bb0b25fa", "1a96bc3e-5444-4da5-b029-636753b68052"]=>4,
    #  ["6083766f-e112-46e7-b4df-7c63c50d5b89", "2d5d8f85-2e42-4e36-9efa-5eebd855eb71"]=>1,
    #  ["6083766f-e112-46e7-b4df-7c63c50d5b89", "690d219a-e22e-4b1c-b90a-151787f659c4"]=>1}
    # get users first
    # SELECT distinct(user_id) FROM subscription_notifications JOIN subscriptions ON subscriptions.id=subscription_notifications.subscription_id WHERE subscription_notifications.created_at>'2018-09-30' AND sent=FALSE;
    # for each user get subs
    # for each sub get sample opp and count
    struct = {}
    struct[:subscriptions] = {}

    results.each do |user_id, opp_count|
      struct[:count] = opp_count

      subscriptions = SubscriptionNotification.joins(:subscription).where('subscription_notifications.created_at >= ? and subscription_notifications.created_at <= ? and subscriptions.user_id = ? and sent=false', yesterday_date, today_date, user_id).group(:subscription_id).count(:opportunity_id)

      subscriptions.each do |subscription_id, subscription_count|
        sample_opportunity = SubscriptionNotification.where(subscription_id: subscription_id).where(sent:false).where('subscription_notifications.created_at >= ? and subscription_notifications.created_at < ?', yesterday_date, today_date).select(:opportunity_id).sample(1).first.opportunity
        subscription = Subscription.find(subscription_id)

        struct[:subscriptions][subscription_id] = {
            title: subscription.title,
            count: subscription_count
        }

        struct[:subscriptions][subscription_id][:opportunity] = {
                title: sample_opportunity.title,
                slug: sample_opportunity.slug,
                description: sample_opportunity.description,
                source: sample_opportunity.source
        }


      end
      puts struct
      OpportunityMailer.send_opportunity(User.find(user_id), struct).deliver_later!

      # update subscription notifications to sent=true
      subscriptions.each do |sub, count|
        subscription = Subscription.find(sub)
        sub_nots = SubscriptionNotification.where(subscription_id: subscription).where(sent:false).where('subscription_notifications.created_at >= ? and subscription_notifications.created_at < ?', yesterday_date, today_date)
        sub_nots.update_all(sent: true) unless Rails.env.development?
      end
    end


    # user_with_notification_opportunity_ids = {}
    # results.each do |result|
    #   if result.subscription.user_id
    #     user_with_notification_opportunity_ids[result.subscription.user_id] ||= Set.new
    #     user_with_notification_opportunity_ids[result.subscription.user_id].add(result.opportunity_id)
    #   end
    # end
    #
    # user_with_notification_opportunity_ids.each do |user_id, opportunity_ids|
    #   opportunities = []
    #   opportunity_ids.each do |opportunity_id|
    #     opportunities.push(Opportunity.find(opportunity_id))
    #   end
    #   OpportunityMailer.send_opportunity(User.find(user_id), opportunities).deliver_later!
    # end

    # once we've sent notifications, update sent to true to avoid sending the same notifications again in the future
    # results.update_all(sent: true) unless Rails.env.development?
  end
end
