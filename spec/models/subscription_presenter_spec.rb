# coding: utf-8
require 'rails_helper'

RSpec.describe SubscriptionPresenter do
  describe '#description' do
    it 'returns the search_term if no filters are set' do
      subscription = create(:subscription, search_term: 'cheese')
      expect(SubscriptionPresenter.new(subscription).description).to eq 'cheese'
    end

    it 'returns search term plus filter if both set' do
      india = create(:country, slug: 'india', name: 'India')
      subscription = create(:subscription, search_term: 'food', countries: [india])

      presenter = SubscriptionPresenter.new(subscription)
      expect(presenter.description).to eq 'food, India'
    end

    it 'returns search term plus multiple filters if set' do
      india = create(:country, slug: 'india', name: 'India')
      aviation = create(:sector, slug: 'aviation', name: 'Aviation')
      subscription = create(:subscription, search_term: 'food', countries: [india], sectors: [aviation])

      presenter = SubscriptionPresenter.new(subscription)
      expect(presenter.description).to eq 'food, India, Aviation'
    end

    it 'returns "all opportunities" when nothing is set' do
      subscription = create(:subscription, search_term: nil)
      presenter = SubscriptionPresenter.new(subscription)

      expect(presenter.description).to eq 'all opportunities'
    end
  end

  describe 'listing countries, sectors, types and values' do
    it 'returns a list of country names' do
      subscription = create(:subscription, countries: [create(:country, name: 'Bhutan'), create(:country, name: 'India'), create(:country, name: 'China')])
      presenter = SubscriptionPresenter.new(subscription)

      expect(presenter.country_names).to eq 'Bhutan, India and China'
    end

    it 'returns a list of sectors' do
      subscription = create(:subscription, sectors: [create(:sector, name: 'Gardening'), create(:sector, name: 'Fuel'), create(:sector, name: 'Refrigeration')])
      presenter = SubscriptionPresenter.new(subscription)

      expect(presenter.sector_names).to eq 'Gardening, Fuel and Refrigeration'
    end

    it 'returns a list of values' do
      subscription = create(:subscription, values: [create(:value, name: 'Less than £10k'), create(:value, name: '£100k+'), create(:value, name: '£1m+')])
      presenter = SubscriptionPresenter.new(subscription)

      expect(presenter.value_names).to eq 'Less than £10k, £100k+ and £1m+'
    end

    it 'returns a list of types' do
      subscription = create(:subscription, types: [create(:type, name: 'Private Sector'), create(:type, name: 'Public Sector'), create(:type, name: 'Aid-funded business')])
      presenter = SubscriptionPresenter.new(subscription)

      expect(presenter.type_names).to eq 'Private Sector, Public Sector and Aid-funded business'
    end
  end

  describe '#search_path' do
    it 'creates the correct url for a subscription with search term only' do
      subscription = create(:subscription, countries: [], search_term: 'feta')
      presenter = SubscriptionPresenter.new(subscription)

      expect(presenter.search_path).to eq('/export-opportunities/opportunities/?s=feta&subscription_url=true')
    end

    it 'creates the correct url for a subscription with countries only' do
      countries = [create(:country, slug: 'Greece'), create(:country, slug: 'Macedonia')]
      subscription = create(:subscription, countries: countries, search_term: '')
      presenter = SubscriptionPresenter.new(subscription)

      expect(presenter.search_path).to eq('/export-opportunities/opportunities/?countries%5B%5D=Greece&countries%5B%5D=Macedonia&s=&subscription_url=true')
    end

    it 'creates the correct url for a subscription with search term and countries' do
      countries = [create(:country, slug: 'Greece'), create(:country, slug: 'Macedonia')]
      subscription = create(:subscription, countries: countries, search_term: 'halva')
      presenter = SubscriptionPresenter.new(subscription)

      expect(presenter.search_path).to eq('/export-opportunities/opportunities/?countries%5B%5D=Greece&countries%5B%5D=Macedonia&s=halva&subscription_url=true')
    end
  end

  describe '#short_description' do
    it 'returns nothing where there are filters but no search' do
      subscription = create(:subscription, countries: [create(:country)], search_term: nil)
      presenter = SubscriptionPresenter.new(subscription)

      expect(presenter.short_description).to eq ''
    end

    it 'returns "All opportunities" when there is no searching or filtering associated' do
      subscription = create(:subscription, search_term: nil)
      presenter = SubscriptionPresenter.new(subscription)

      expect(presenter.short_description).to eq 'All opportunities'
    end

    it 'returns a search term if available' do
      subscription = create(:subscription, countries: [create(:country)], search_term: 'foo')
      presenter = SubscriptionPresenter.new(subscription)

      expect(presenter.short_description).to eq 'Search term: foo'
    end
  end
end
