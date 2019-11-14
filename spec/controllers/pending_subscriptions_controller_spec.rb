require 'rails_helper'

RSpec.describe PendingSubscriptionsController, sso: true do
  describe '#create' do
    it 'creates a pending subscription' do
      subscription_attrs = {
            query: {
              search_term: 'innovative',
              countries: ['france'],
              sectors: ['aerospace'],
            },
      }

      expect { post :create, params: { subscription: subscription_attrs } }.to change { PendingSubscription.count }.by(1)
      expect(response).to have_http_status(302)
    end
  end

  describe '#update' do
    it 'activates a subscription identified by its uuid' do
      user = create(:user)
      sign_in user

      create(:country, slug: 'france')
      create(:sector, slug: 'aerospace')

      subscription_attrs = {
          query: {
            search_term: 'innovative',
            countries: ['france'],
            sectors: ['aerospace'],
          },
      }

      pending_subscription = create(:pending_subscription, query_params: subscription_attrs)

      expect { get :update, params: { id: pending_subscription.id } }.to change { Subscription.count }.by(1)

      expect(pending_subscription.reload.subscription_id).not_to be_nil
    end
  end
end
