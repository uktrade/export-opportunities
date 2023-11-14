require 'rails_helper'

RSpec.describe SendOpportunitiesDigest, :elasticsearch, :commit, sidekiq: :inline do
  it 'creates a valid object with one notification to send' do
    ActionMailer::Base.deliveries.clear

    notification_creation_timestamp = Time.zone.now - 1.day + 3.hours
    user = create(:user)
    subscription = create(:subscription, user: user)
    opportunity = create(:opportunity, :published)
    subscription_notification = create(:subscription_notification, subscription: subscription, opportunity: opportunity, created_at: notification_creation_timestamp, sent: false)
    SendOpportunitiesDigest.new.perform

    subscription_notification.reload

    expect(subscription_notification.sent).to eq true
  end

  it 'picks the DBT opportunity when there is one' do
    ActionMailer::Base.deliveries.clear

    notification_creation_timestamp = Time.zone.now - 1.day + 3.hours
    user = create(:user)
    subscription = create(:subscription, user: user)

    dit_opportunity = create(:opportunity, :published, source: :post)
    create(:subscription_notification, subscription: subscription, opportunity: dit_opportunity, created_at: notification_creation_timestamp)

    third_party_opportunity = create(:opportunity, :published, source: :volume_opps)
    create(:subscription_notification, subscription: subscription, opportunity: third_party_opportunity, created_at: notification_creation_timestamp)

    SendOpportunitiesDigest.new.perform

    last_delivery = ActionMailer::Base.deliveries.last

    expect(last_delivery.text_part.to_s).to include(dit_opportunity.title)
    expect(last_delivery.text_part.to_s).to_not include(third_party_opportunity.title)
  end

  it 'picks the 3rd party opportunity when there is no DBT opp for the subscription' do
    ActionMailer::Base.deliveries.clear

    notification_creation_timestamp = Time.zone.now - 1.day + 3.hours
    user = create(:user)
    subscription = create(:subscription, user: user)

    third_party_opportunity = create(:opportunity, :published, source: :volume_opps)
    create(:subscription_notification, subscription: subscription, opportunity: third_party_opportunity, created_at: notification_creation_timestamp)

    SendOpportunitiesDigest.new.perform

    last_delivery = ActionMailer::Base.deliveries.last

    expect(last_delivery.text_part.to_s).to include(third_party_opportunity.title)
  end
end
