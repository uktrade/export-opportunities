class SendOpportunitiesDigest
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform
    today_date = Time.zone.now.strftime('%Y-%m-%d')
    tomorrow_date = (Time.zone.now + 1.day).strftime('%Y-%m-%d')

    # TODO: fix \/\/\/ with proper rails structure
    results = ActiveRecord::Base.connection.execute("SELECT subscriptions.user_id, subscription_notifications.opportunity_id FROM subscription_notifications JOIN subscriptions ON subscriptions.id=subscription_notifications.subscription_id WHERE subscription_notifications.created_at>=#{today_date} AND subscription_notifications.created_at<=#{tomorrow_date}")

    user_with_notification_opportunity_ids = Hash.new{|h,k| h[k] = [] }
    results.each do |result|
      user_with_notification_opportunity_ids[result['user_id']].push(result['opportunity_id'])
    end

    user_with_notification_opportunity_ids.each do |user_id, opportunity_ids|
      opportunities = []
      opportunity_ids.each do |opportunity_id|
        opportunities.push(Opportunity.find(opportunity_id))
      end
      OpportunityMailer.send_opportunity(User.find(user_id), opportunities.first(5))
    end
  end
end
