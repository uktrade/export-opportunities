require 'rails_helper'

RSpec.describe SubscriptionFinder, :elasticsearch, :commit, type: :service do

  describe '#call' do
    context 'when filtering by one or more categories' do
      it 'returns a list of subscriptions which match the given opportunity' do
        search_term = 'bar'
        sectors = create_list(:sector, 2)
        opportunity = create(:opportunity, title: search_term, sectors: sectors)

        first_subscription = create(:subscription, search_term: search_term, sectors: sectors)
        second_subscription = create(:subscription, search_term: search_term, sectors: [sectors[0]])
        irrelevant_subscription = create(:subscription, search_term: search_term, sectors: [create(:sector)])

        refresh_elasticsearch
        response = SubscriptionFinder.new.call(opportunity)

        expect(response).to include(first_subscription)
        expect(response).to include(second_subscription)
        expect(response).to_not include(irrelevant_subscription)
      end

      it 'includes opportunities in categories the subscription is not filtering on' do
        search_term = 'baz'
        sectors = [create(:sector)]
        countries = [create(:country)]

        opportunity = create(:opportunity, title: search_term, sectors: sectors, countries: countries)

        first_subscription = create(:subscription, search_term: search_term, sectors: [], countries: countries)
        second_subscription = create(:subscription, search_term: search_term, sectors: sectors, countries: [])

        refresh_elasticsearch
        response = SubscriptionFinder.new.call(opportunity)

        expect(response).to include(first_subscription)
        expect(response).to include(second_subscription)
      end

      it 'includes subscriptions which have no category preferences' do
        search_term = 'bar'
        sectors = [create(:sector)]
        countries = [create(:country)]
        types = [create(:type)]
        values = [create(:value)]

        opportunity = create(:opportunity,
          title: search_term, countries: countries, sectors: sectors, types: types, values: values)
        subscription = create(:subscription,
          search_term: search_term, countries: [], sectors: [], types: [], values: [])

        refresh_elasticsearch
        response = SubscriptionFinder.new.call(opportunity)

        expect(response).to include(subscription)
      end

      it 'returns subscriptions which match multiple sectors only once' do
        search_term = 'biz'
        sectors = create_list(:sector, 2)
        opportunity = create(:opportunity, title: search_term, sectors: sectors)
        subscription = create(:subscription, search_term: search_term, sectors: sectors)

        refresh_elasticsearch
        response = SubscriptionFinder.new.call(opportunity)

        expect(response).to include(subscription)
        expect(response.size).to eql 1
      end

      it 'only returns subscriptions that are confirmed' do
        countries = [create(:country)]
        opportunity = create(:opportunity, countries: countries)
        unconfirmed_subscription = create(:subscription, :unconfirmed, countries: countries)

        refresh_elasticsearch
        response = SubscriptionFinder.new.call(opportunity)

        expect(response).to_not include(unconfirmed_subscription)
      end
    end

    context 'when filtering by keywords' do
      it 'returns a list of subscriptions which match the given opportunity' do
        opportunity = create(:opportunity, title: 'UK – Coffee sought after by Shoreditch-based company.')
        matching_subscription = create(:subscription, search_term: 'shoreditch')
        non_matching_subscription = create(:subscription, search_term: 'bermondsey')

        refresh_elasticsearch
        response = SubscriptionFinder.new.call(opportunity)

        expect(response).to include(matching_subscription)
        expect(response).to_not include(non_matching_subscription)
      end

      it 'returns a list of subscriptions whose keywords ALL match the given opportunity' do
        opportunity = create(:opportunity, title: 'Italy - Coffee and Tea')

        matching_subscription = create(:subscription, search_term: 'tea coffee')
        non_matching_subscription = create(:subscription, search_term: 'coffee computers')

        refresh_elasticsearch
        response = SubscriptionFinder.new.call(opportunity)

        expect(response).to include(matching_subscription)
        expect(response).to_not include(non_matching_subscription)
      end

      context 'when the search_term is (somehow) nil' do
        it 'does not return the subscription' do
          opportunity = create(:opportunity)
          subscription = build(:subscription, search_term: nil)
          subscription.save(validate: false)

          refresh_elasticsearch
          response = SubscriptionFinder.new.call(opportunity)

          expect(response).to include(subscription)
        end
      end

      context 'when the search_term is (somehow) an empty string' do
        it 'does not return the subscription' do
          opportunity = create(:opportunity)
          subscription = build(:subscription, search_term: '')
          subscription.save(validate: false)

          refresh_elasticsearch
          response = SubscriptionFinder.new.call(opportunity)

          expect(response).to include(subscription)
        end
      end
    end
  end

  context 'when filtering by keywords and categories' do
    it 'returns subscriptions that match both keywords and categories', focus: true do
      country = create(:country)
      other_country = create(:country)

      opportunity = create(:opportunity, title: 'Brazil - solutions for animal diseases')
      opportunity.countries << country

      matching_subscription = create(:subscription, search_term: 'animal diseases', countries: [country])
      non_matching_subscription = create(:subscription, search_term: 'animal diseases', countries: [other_country])

      refresh_elasticsearch
      response = SubscriptionFinder.new.call(opportunity)

      expect(response).to include(matching_subscription)
      expect(response).to_not include(non_matching_subscription)
    end

    it 'does not return unsubscribed subscriptions' do
      countries = [create(:country)]
      opportunity = create(:opportunity, countries: countries)
      unsubscribed_subscription = create(:subscription, unsubscribed_at: DateTime.yesterday, countries: countries)

      refresh_elasticsearch
      response = SubscriptionFinder.new.call(opportunity)

      expect(response).to_not include(unsubscribed_subscription)
    end
  end

  context 'when subscribing to sectors' do
    it 'returns matching subscriptions' do
      sectors = [create(:sector)]
      opportunity = create(:opportunity, title: 'foo', sectors: sectors)
      matching_subscription = create(:subscription, search_term: 'foo', sectors: sectors)

      refresh_elasticsearch
      response = SubscriptionFinder.new.call(opportunity)

      expect(response).to include(matching_subscription)
    end
  end

  context 'when subscribing to values' do
    it 'returns matching subscriptions' do
      values = [create(:value)]
      opportunity = create(:opportunity, title: 'foo', values: values)
      matching_subscription = create(:subscription, search_term: 'foo', values: values)

      refresh_elasticsearch
      response = SubscriptionFinder.new.call(opportunity)

      expect(response).to include(matching_subscription)
    end
  end

  context 'when subscribing to types' do
    it 'returns matching subscriptions' do
      types = [create(:type)]
      opportunity = create(:opportunity, title: 'foo', types: types)
      matching_subscription = create(:subscription, search_term: 'foo', types: types)

      refresh_elasticsearch
      response = SubscriptionFinder.new.call(opportunity)

      expect(response).to include(matching_subscription)
    end
  end

  context 'when someone subscribes to multiple filters' do
    it 'returns matching subscriptions' do
      countries = [create(:country), create(:country)]
      sectors = [create(:sector), create(:sector)]
      types = [create(:type), create(:type)]
      values = [create(:value), create(:value)]

      opportunity = create(:opportunity, title: 'foo',
                                         countries: countries, sectors: sectors, types: types, values: values)
      matching_subscription = create(:subscription, search_term: 'foo',
                                                    countries: [countries.first], sectors: [sectors.first], types: [types.first], values: [values.first])

      refresh_elasticsearch
      response = SubscriptionFinder.new.call(opportunity)

      expect(response).to include(matching_subscription)
    end
  end
end
