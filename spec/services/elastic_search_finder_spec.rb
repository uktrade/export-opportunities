require 'rails_helper'
#require 'app/services/elastic_search_finder' # Maybe?

RSpec.describe ElasticSearchFinder do
  
  setup do

  end

  # We need to put in the Opportunity Search Builder 
  # Test that Opportunity Search Builder works
  # Then, to test the ElasticSearchFinder
  # Create a valid OpportunitySearchBuilder

  describe "call" do
    it "provides a set number of results" do

      query = OpportunitySearchBuilder.new(dit_boost_search: dit_boost_search,
                                           search_term: search_term,
                                           sectors: filters.sectors,
                                           countries: filters.countries,
                                           opportunity_types: filters.types,
                                           values: filters.values,
                                           sort: sort,
                                           sources: filters.sources).call

      query = {
        bool: {
          must: [keyword_query,
                 sector_query,
                 country_query,
                 opportunity_type_query,
                 value_query,
                 expired_query,
                 status_query,
                 source_query]
        },
      }
      sort = [{ first_published_at: { order: :desc } }]
      limit = 

      expect(ElasticSearchFinder.call(query, sort, limit)).to be {

      }
    end
  end
end