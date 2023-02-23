require 'rails_helper'

RSpec.describe AddOpportunityToMatchingSubscriptionsQueueWorker, :elasticsearch, :commit, sidekiq: :inline do
  it 'sends an opportunity to one or more subscribers' do
    opportunity = create(:opportunity, title: 'matching')
    create_list(:subscription, 2, search_term: 'matching')

    expect do
      AddOpportunityToMatchingSubscriptionsQueueWorker.perform_later(opportunity.id)
    end.to change { SubscriptionNotification.count }.by(2)
  end

  it 'sends an opportunity to a user once' do
    user = create(:user, email: 'dupe@example.com')
    opportunity = create(:opportunity, title: 'matching')
    create_list(:subscription, 2, user: user, search_term: 'matching')

    expect do
      AddOpportunityToMatchingSubscriptionsQueueWorker.perform_later(opportunity.id)
    end.to change { SubscriptionNotification.count }.by(1)
  end

  it 'sends an opportunity to a user once, even with multiple matching subscriptions' do
    user = create(:user, email: 'dupe@example.com')
    opportunity = create(:opportunity, title: 'matching subscription')
    create(:subscription, user: user, search_term: 'matching')
    create(:subscription, user: user, search_term: 'subscription')

    expect do
      AddOpportunityToMatchingSubscriptionsQueueWorker.perform_later(opportunity.id)
    end.to change { SubscriptionNotification.count }.by(1)
  end

  describe 'logging the notifications it sends' do
    it 'adds a subscription notification record' do
      opportunity = create(:opportunity, title: 'matching subscription')
      subscription = create(:subscription, search_term: 'matching')

      expect do
        AddOpportunityToMatchingSubscriptionsQueueWorker.perform_later(opportunity.id)
      end.to change { subscription.notifications.count }.by(1)

      expect(subscription.notifications.last.opportunity).to eq opportunity
    end

    it 'records whether or not the notification was sent' do
      opportunity = create(:opportunity, title: 'matching subscription')
      user = create(:user, email: 'email@example.com')
      first_subscription = create(:subscription, user: user, search_term: 'matching')
      second_subscription = create(:subscription, user: user, search_term: 'subscription')

      # Ugh, but it is necessary to control the order these subscriptions are returned
      expect_any_instance_of(SubscriptionFinder).to receive(:call).and_return([first_subscription, second_subscription])

      expect do
        AddOpportunityToMatchingSubscriptionsQueueWorker.perform_later(opportunity.id)
      end.to change { SubscriptionNotification.count }.by(1)
    end
  end
end
