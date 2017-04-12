require 'rails_helper'

RSpec.describe OpportunitySearchBuilder do
  before(:each) do
    @sort = OpenStruct.new(column: :response_due_on, order: :desc)
  end
  describe '#call' do
    it 'returns the default search query with no parameters' do
      builder = OpportunitySearchBuilder.new(sort: @sort).call

      expected_hash = {
        match_all: {},
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:must]).to include(expected_hash)
    end

    it 'builds a keyword search when a search term is provided' do
      builder = OpportunitySearchBuilder.new(search_term: 'cheese', sort: @sort).call

      expected_hash = {
        multi_match: {
          query: 'cheese',
          fields: ['title^5', 'teaser^2', 'description'],
          operator: 'and',
        },
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:must]).to include(expected_hash)
    end

    it 'filters by a single sector' do
      builder = OpportunitySearchBuilder.new(sectors: 'food', sort: @sort).call

      expected_sectors_hash = {
        bool: {
          should: {
            terms: {
              "sectors.slug": ['food'],
            },
          },
        },
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:must]).to include(expected_sectors_hash)
    end

    it 'filters by multiple sectors' do
      builder = OpportunitySearchBuilder.new(sectors: %w(food drink), sort: @sort).call

      expected_sectors_hash = {
        bool: {
          should: {
            terms: {
              "sectors.slug": %w(food drink),
            },
          },
        },
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:must]).to include(expected_sectors_hash)
    end

    it 'filters by multiple countries' do
      builder = OpportunitySearchBuilder.new(countries: %w(albania iran), sort: @sort).call

      expected_sectors_hash = {
        bool: {
          should: {
            terms: {
              "countries.slug": %w(albania iran),
            },
          },
        },
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:must]).to include(expected_sectors_hash)
    end

    it 'filters by multiple opportunity types' do
      builder = OpportunitySearchBuilder.new(opportunity_types: ['Private Sector'], sort: @sort).call

      expected_sectors_hash = {
        bool: {
          should: {
            terms: {
              "types.slug": ['Private Sector'],
            },
          },
        },
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:must]).to include(expected_sectors_hash)
    end

    it 'filters by multiple contract values' do
      builder = OpportunitySearchBuilder.new(values: ['More than £100k'], sort: @sort).call

      expected_sectors_hash = {
        bool: {
          should: {
            terms: {
              "values.slug": ['More than £100k'],
            },
          },
        },
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:must]).to include(expected_sectors_hash)
    end
  end
end
