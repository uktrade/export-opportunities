require 'rails_helper'

RSpec.describe OpportunitySearchBuilder do

  # OLD:
  #@sort = OpenStruct.new(column: :response_due_on, order: :desc)
  # NEW:

  before(:each) do
    @sort = OpportunitySort.new(default_column: 'first_published_at',
                                default_order: 'desc')
    @boost = false

    create(:opportunity, title: 'Aardvark', created_at: 2.months.ago, response_due_on: 12.months.from_now)
    create(:opportunity, title: 'Bear', created_at: 3.months.ago, response_due_on: 24.months.from_now)
    create(:opportunity, title: 'Capybara', created_at: 1.month.ago, response_due_on: 18.months.from_now)
    sleep 1
    Opportunity.__elasticsearch__.create_index!(force: true)
    Opportunity.__elasticsearch__.refresh_index!
    sleep 1
  end

  describe "#call", elasticsearch: true do
    it 'returns a valid search object', focus: true do
      query_builder = OpportunitySearchBuilder.new(sort: @sort,
                                                   dit_boost_search: @boost)
      query = query_builder.call
      search = Opportunity.__elasticsearch__.search(query: query[:search_query],
                                                    sort:  query[:search_sort])
      debugger
      expect(search.results.count).to eq 3
    end
  end

  # Testing strategy:
  # Create a valid OpportunitySearchBuilder object
  # Confirm it works by running through the ElasticSearchFinder object
  # 
  # Strictly speaking, this object does is tightly coupled to the 
  # ElasticSearchFinder object, and the objects should be merged.
  # 
  # Each of the filters accept valid terms, and work
  # ?? Each of the filters reject invalid terms (?)
  # Invalidate it by breaking each of the inputs in turn

  describe '#call' do
    it 'returns the default search query with no parameters' do
      builder = OpportunitySearchBuilder.new(sort: @sort, dit_boost_search: false).call

      expected_hash = {
        match_all: {},
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:must]).to include(expected_hash)
    end

    it 'builds a keyword search when a search term is provided' do
      builder = OpportunitySearchBuilder.new(search_term: 'cheese', sort: @sort, dit_boost_search: false).call

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
      builder = OpportunitySearchBuilder.new(sectors: 'food', sort: @sort, dit_boost_search: false).call

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
      builder = OpportunitySearchBuilder.new(sectors: %w[food drink], sort: @sort, dit_boost_search: false).call

      expected_sectors_hash = {
        bool: {
          should: {
            terms: {
              "sectors.slug": %w[food drink],
            },
          },
        },
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:must]).to include(expected_sectors_hash)
    end

    it 'filters by multiple countries' do
      builder = OpportunitySearchBuilder.new(countries: %w[albania iran], sort: @sort, dit_boost_search: false).call

      expected_sectors_hash = {
        bool: {
          should: {
            terms: {
              "countries.slug": %w[albania iran],
            },
          },
        },
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:must]).to include(expected_sectors_hash)
    end

    it 'filters by multiple opportunity types' do
      builder = OpportunitySearchBuilder.new(opportunity_types: ['Private Sector'], sort: @sort, dit_boost_search: false).call

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
      builder = OpportunitySearchBuilder.new(values: ['More than £100k'], sort: @sort, dit_boost_search: false).call

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
