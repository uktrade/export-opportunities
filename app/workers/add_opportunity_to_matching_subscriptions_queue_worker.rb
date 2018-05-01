class AddOpportunityToMatchingSubscriptionsQueueWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(opportunity_id)
    email_addresses_notified = {}
    opportunity = Opportunity.find(opportunity_id)
    matching_subscriptions = SubscriptionFinder.new.call(opportunity)

    matching_subscriptions.each do |subscription|
      # we already sent notification email for this user through another subscription
      if email_addresses_notified.include?(subscription.email)
        # subscription.notifications.create!(opportunity_id: opportunity_id, sent: false)
      else
        # create a new notification and save it as sent false until we actually send it
        subscription.notifications.create!(opportunity_id: opportunity_id, sent: false)
        unless Rails.env.test?
          logger.info "Queueing alert for opportunity #{opportunity.id} to #{subscription.email}"
        end
        # OpportunityMailer.send_opportunity(opportunity, subscription).deliver_later!
        email_addresses_notified[subscription.email] = true
      end
    end
  end
end
