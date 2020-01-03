require 'rails_helper'

RSpec.describe SubscriptionsController, sso: true do
  describe '#show' do
    it 'marks a subscription as confirmed' do
      token = SecureRandom.uuid
      subscription = create(:subscription, confirmation_token: token)
      get :show, params: { confirmation_token: token }

      subscription.reload
      expect(subscription).to be_confirmed
    end

    it 'responds with 201 when subscription is confirmed' do
      token = SecureRandom.uuid
      create(:subscription, confirmation_token: token)
      get :show, params: { confirmation_token: token }
      expect(response).to be_accepted
    end

    it 'responds with 404 when subscription cannot be found' do
      token = SecureRandom.uuid
      get :show, params: { confirmation_token: token }
      expect(response).to be_not_found
    end

    it 'responds with 404 when confirmation token missing' do
      get :show
      expect(response).to be_not_found
    end
  end

  describe '#create' do
    before(:each) do
      user = create(:user, email: 'test@example.com')

      sign_in user
    end

    context 'with a valid email address' do
      it 'creates an unconfirmed subscription based on search term' do
        subscription_attrs = {
          params:{
            subscription: {
              s: 'fish',
            },
          },
        }

        expect { post :create, subscription_attrs }.to change { Subscription.count }.by(1)

        subscription = Subscription.last
        expect(subscription.email).to eql 'test@example.com'
        expect(subscription.search_term).to eql 'fish'
        expect(subscription.confirmed_at).to be_present
      end

      it 'creates an unconfirmed subscription based on CPV code' do
        subscription_attrs = {
          params:{
            subscription: {
              cpvs: ['1', '2']
            },
          },
        }

        expect { post :create, subscription_attrs }.to change { Subscription.count }.by(1)

        subscription = Subscription.last
        expect(subscription.email).to eql 'test@example.com'
        expect(subscription.cpv_industry_ids).to eql '1,2'
        expect(subscription.confirmed_at).to be_present
      end
    end

    context 'with filters' do
      it 'creates an unconfirmed subscription' do
        skip('TO DO - have we removed some code to allow users to subscribe to all opps without any params')
        sectors = create_list(:sector, 2)
        types = create_list(:type, 2)
        countries = create_list(:country, 2)
        values = create_list(:value, 2)

        subscription_attrs = {
          subscription: {
            params: {
              sectors: sectors.collect(&:slug),
              types: types.collect(&:slug),
              countries: countries.collect(&:slug),
              values: values.collect(&:slug),
            },
          },
        }

        expect { post :create, subscription_attrs }.to change { Subscription.count }.by(1)

        subscription = Subscription.last
        expect(subscription.email).to eql 'test@example.com'
        expect(subscription.search_term).to be_empty
        expect(subscription.sectors).to eq(sectors)
        expect(subscription.types).to eq(types)
        expect(subscription.countries).to eq(countries)
        expect(subscription.values).to eq(values)
        expect(subscription.confirmed_at).to be_present
      end
    end

    context 'with a search term and filters' do
      it 'creates an unconfirmed subscription' do
        sectors = create_list(:sector, 2)
        types = create_list(:type, 2)
        countries = create_list(:country, 2)
        values = create_list(:value, 2)

        subscription_attrs = {
          params: {
            subscription: {
              s: 'compressors',
              sectors: sectors.collect(&:slug),
              types: types.collect(&:slug),
              countries: countries.collect(&:slug),
              values: values.collect(&:slug),
            },
          },
        }

        expect { post :create, subscription_attrs }.to change { Subscription.count }.by(1)

        subscription = Subscription.last
        expect(subscription.email).to eql 'test@example.com'
        expect(subscription.search_term).to eq('compressors')
        expect(subscription.sectors).to eq(sectors)
        expect(subscription.types).to eq(types)
        expect(subscription.countries).to eq(countries)
        expect(subscription.values).to eq(values)

        expect(subscription.confirmed_at).to be_present
      end
    end
  end

  describe '#destroy' do
    it 'marks a subscription as unsubscribed, and records the date' do
      user = create(:user, email: 'test@example.com')
      sign_in user

      travel(0.seconds) do
        mock_sso_with(email: Faker::Internet.email)

        subscription = create(:subscription)

        delete :destroy, params: { id: subscription.id }
        subscription.reload

        expect(subscription.unsubscribed_at).to eq DateTime.current
      end
    end

    it 'invokes sso for a user after the cutoff date' do
      user = create(:user)
      subscription = create(:subscription, user: user)

      expect(controller).to receive(:require_sso!).and_return(true)

      delete :destroy, params: { id: subscription.id }
    end
  end

  describe '#update' do
    it 'records the reason for unsubscribing' do
      subscription = create(:subscription)

      put :update, params: { id: subscription.id, reason: 'spam' }
      subscription.reload

      expect(subscription.unsubscribe_reason).to eql 'spam'
    end

    it 'ignores invalid reasons for unsubscribing' do
      subscription = create(:subscription)

      put :update, params: { id: subscription.id, reason: 'xyz' }
      subscription.reload

      expect(subscription.unsubscribe_reason).to be_nil
    end
  end
end
