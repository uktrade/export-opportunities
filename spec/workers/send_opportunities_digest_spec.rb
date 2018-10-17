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

  it 'picks the DIT opportunity when there is one' do
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

  it 'picks the 3rd party opportunity when there is no DIT opp for the subscription' do
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

  it 'creates the correct target_url for a subscription with search term only' do
    user = create(:user)
    subscription = create(:subscription, user: user, search_term: 'feta')
    target_url = SendOpportunitiesDigest.new.url_from_subscription(subscription)
    expect(target_url).to eq('/opportunities?s=feta')
  end

  it 'creates the correct target_url for a subscription with countries only' do
    user = create(:user)
    country = create(:country, slug: 'Greece')
    another_country = create(:country, slug: 'Macedonia')
    subscription = create(:subscription, user: user, countries: [country, another_country], search_term: '')

    target_url = SendOpportunitiesDigest.new.url_from_subscription(subscription)

    expect(target_url).to eq('/opportunities?s=&countries%5B%5D=Greece&countries%5B%5D=Macedonia')
  end

  it 'creates the correct target_url for a subscription with search term and countries' do
    user = create(:user)
    country = create(:country, slug: 'Greece')
    another_country = create(:country, slug: 'Macedonia')
    subscription = create(:subscription, user: user, search_term: 'halva', countries: [country, another_country])

    target_url = SendOpportunitiesDigest.new.url_from_subscription(subscription)

    expect(target_url).to eq('/opportunities?s=halva&countries%5B%5D=Greece&countries%5B%5D=Macedonia')
  end
end
