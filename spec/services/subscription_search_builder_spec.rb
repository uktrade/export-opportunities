require 'rails_helper'

RSpec.describe SubscriptionSearchBuilder do
  describe '#call' do
    it 'returns the default search query with no parameters' do
      builder = SubscriptionSearchBuilder.new.call

      expected_hash = {
        match_all: {},
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:must]).to include(expected_hash)
    end

    # it 'builds a keyword search when a search term is provided' do
    #   builder = SubscriptionSearchBuilder.new(search_term: 'cheese').call
    #
    #   expected_hash = {
    #     multi_match: {
    #       query: 'cheese',
    #       fields: ['search_term'],
    #       operator: 'and',
    #     },
    #   }
    #
    #   expect(builder).to be_a(Hash)
    #   expect(builder[:search_query][:bool][:must]).to include(expected_hash)
    # end

    it 'filters by a single sector' do
      builder = SubscriptionSearchBuilder.new(sectors: 'food').call

      expected_sectors_hash = {
        terms: {
          'sectors.id': ['food'],
        },
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:should].first).to include(expected_sectors_hash)
    end

    it 'filters by multiple sectors' do
      builder = SubscriptionSearchBuilder.new(sectors: %w[food drink]).call

      expected_sectors_hash = {
        terms: {
          'sectors.id': %w[food drink],
        },
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:should].first).to include(expected_sectors_hash)
    end

    it 'filters by multiple countries' do
      builder = SubscriptionSearchBuilder.new(countries: %w[albania iran]).call

      expected_sectors_hash = {
        terms: {
          'countries.id': %w[albania iran],
        },
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:should].first).to include(expected_sectors_hash)
    end

    it 'filters by multiple opportunity types' do
      builder = SubscriptionSearchBuilder.new(opportunity_types: ['Private Sector']).call

      expected_sectors_hash = {
        terms: {
          'types.id': ['Private Sector'],
        },
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:should].first).to include(expected_sectors_hash)
    end

    it 'filters by multiple contract values' do
      builder = SubscriptionSearchBuilder.new(values: ['More than £100k']).call

      expected_sectors_hash = {
        terms: {
          'values.id': ['More than £100k'],
        },
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:should].first).to include(expected_sectors_hash)
    end
  end
end
