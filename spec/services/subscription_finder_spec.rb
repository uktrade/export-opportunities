# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubscriptionFinder, :elasticsearch, :commit, type: :service do
  describe '.call' do
    subject { SubscriptionFinder.new.call(opportunity) }

    let(:opportunity) { create(:opportunity, opportunity_params) }
    let(:opportunity_params) { {} }

    context 'when filtering by one or more categories' do
      it 'returns a list of subscriptions which match the given opportunity' do
        search_term = 'bar'
        sectors = create_list(:sector, 2)
        first_subscription = create(
          :subscription, search_term: search_term, sectors: sectors
        )
        second_subscription = create(
          :subscription, search_term: search_term, sectors: [sectors[0]]
        )
        irrelevant_subscription = create(
          :subscription, search_term: search_term, sectors: [create(:sector)]
        )

        opportunity_params.merge!(title: search_term, sectors: sectors)

        sleep 1

        expect(subject).to include(first_subscription)
        expect(subject).to include(second_subscription)
        expect(subject).to_not include(irrelevant_subscription)
      end

      it 'includes opportunities in search for the terms is not filtering on' do
        search_term = 'baz'
        sectors = [create(:sector)]
        countries = [create(:country)]
        first_subscription = create(
          :subscription, search_term: search_term, sectors: [],
                         countries: countries
        )
        second_subscription = create(
          :subscription, search_term: search_term, sectors: sectors,
                         countries: []
        )

        opportunity_params.merge!(
          title: search_term, sectors: sectors, countries: countries
        )

        sleep 1

        expect(subject).to include(first_subscription)
        expect(subject).to include(second_subscription)
      end

      it 'includes subscriptions which have no category preferences' do
        search_term = 'bar'
        sectors = [create(:sector)]
        countries = [create(:country)]
        types = [create(:type)]
        values = [create(:value)]
        subscription = create(
          :subscription, search_term: search_term, countries: [], sectors: [],
                         types: [], values: []
        )

        opportunity_params.merge!(
          title: search_term, countries: countries, sectors: sectors,
          types: types, values: values
        )

        sleep 1

        expect(subject).to include(subscription)
      end

      it 'returns subscriptions which match multiple sectors only once' do
        search_term = 'biz'
        sectors = create_list(:sector, 2)
        subscription = create(
          :subscription, search_term: search_term, sectors: sectors
        )

        opportunity_params.merge!(title: search_term, sectors: sectors)

        sleep 1

        expect(subject).to include(subscription)
        expect(subject.size).to eql 1
      end

      it 'only returns subscriptions that are confirmed' do
        countries = [create(:country)]
        unconfirmed_subscription = create(
          :subscription, :unconfirmed, countries: countries
        )

        opportunity_params.merge!(countries: countries)

        sleep 1

        expect(subject).to_not include(unconfirmed_subscription)
      end
    end

    context 'when filtering by keywords' do
      it 'returns a list of subscriptions which match the given opportunity' do
        matching_subscription = create(:subscription, search_term: 'shoreditch')
        non_matching_subscription = create(:subscription, search_term: 'fulham')

        opportunity_params.merge!(
          title: 'UK – Coffee sought after by Shoreditch-based company.'
        )

        sleep 1

        expect(subject).to include(matching_subscription)
        expect(subject).to_not include(non_matching_subscription)
      end

      it 'returns subscriptions whose keywords ALL match the opportunity' do
        matching_subscription = create(:subscription, search_term: 'tea coffee')
        non_matching_subscription = create(:subscription, search_term: 'yo! tea')

        opportunity_params.merge!(title: 'Italy - Coffee and Tea')

        sleep 1

        expect(subject).to include(matching_subscription)
        expect(subject).to_not include(non_matching_subscription)
      end

      context 'when the search_term is (somehow) nil' do
        it 'does not return the subscription' do
          subscription = build(:subscription, search_term: nil)
          subscription.save(validate: false)

          sleep 1

          expect(subject).not_to include(subscription)
        end
      end

      context 'when the search_term is (somehow) an empty string' do
        it 'does not return the subscription' do
          subscription = build(:subscription, search_term: '')
          subscription.save(validate: false)

          sleep 1

          expect(subject).not_to include(subscription)
        end
      end
    end

    context 'when filtering by keywords and categories' do
      it 'returns subscriptions that match both keywords and categories' do
        country = create(:country)
        other_country = create(:country)
        matching_subscription = create(
          :subscription, search_term: 'animal diseases', countries: [country]
        )
        non_matching_subscription = create(
          :subscription, search_term: 'animal diseases',
                         countries: [other_country]
        )

        opportunity_params.merge!(
          title: 'Brazil - solutions for animal diseases', countries: [country]
        )

        sleep 1

        expect(subject).to include(matching_subscription)
        expect(subject).to_not include(non_matching_subscription)
      end

      it 'does not return unsubscribed subscriptions' do
        countries = [create(:country)]
        unsubscribed_subscription = create(
          :subscription, unsubscribed_at: DateTime.yesterday,
                         countries: countries
        )

        opportunity_params.merge!(countries: countries)

        sleep 1

        expect(subject).to_not include(unsubscribed_subscription)
      end
    end

    context 'when subscribing to sectors' do
      it 'returns matching subscriptions' do
        sectors = [create(:sector)]
        matching_subscription = create(
          :subscription, search_term: 'foo', sectors: sectors
        )

        opportunity_params.merge!(title: 'foo', sectors: sectors)

        sleep 1

        expect(subject).to include(matching_subscription)
      end
    end

    context 'when subscribing to values' do
      it 'returns matching subscriptions' do
        values = [create(:value)]
        matching_subscription = create(
          :subscription, search_term: 'foo', values: values
        )

        opportunity_params.merge!(title: 'foo', values: values)

        sleep 1

        expect(subject).to include(matching_subscription)
      end
    end

    context 'when subscribing to types' do
      it 'returns matching subscriptions' do
        types = [create(:type)]
        matching_subscription = create(
          :subscription, search_term: 'foo', types: types
        )

        opportunity_params.merge!(title: 'foo', types: types)

        sleep 1

        expect(subject).to include(matching_subscription)
      end
    end

    context 'when someone subscribes to multiple filters' do
      it 'returns matching subscriptions' do
        countries = [create(:country), create(:country)]
        sectors = [create(:sector), create(:sector)]
        types = [create(:type), create(:type)]
        values = [create(:value), create(:value)]
        matching_subscription = create(
          :subscription, search_term: 'foo', countries: [countries.sample],
                         sectors: [sectors.sample], types: [types.sample],
                         values: [values.sample]
        )

        opportunity_params.merge!(
          title: 'foo', countries: countries, sectors: sectors, types: types,
          values: values
        )

        sleep 1

        expect(subject).to include(matching_subscription)
      end
    end
  end
end
