require 'rails_helper'

RSpec.describe OpportunitySearchBuilder do

  before(:each) do
    @post_1 = create(:opportunity, title: 'Post 1', first_published_at: 2.months.ago,
                      response_due_on: 12.months.from_now, status: :publish, source: 0)
    create(:opportunity, title: 'Post 2', first_published_at: 3.months.ago,
            response_due_on: 24.months.from_now, status: :publish)
    create(:opportunity, title: 'Post 3', first_published_at: 1.month.ago,
            response_due_on: 18.months.from_now, status: :publish)
  end

  # Returns a query built with OpportunitySeachBuilder
  # with any optional parameters
  def new_query(**args)
    OpportunitySearchBuilder.new(args).call
  end

  # Returns numbers of results for an elastic search
  def results_count(query)
    refresh_elasticsearch
    Opportunity.__elasticsearch__.search(query: query[:query],
                                         sort:  query[:sort]).
                                         results.count
  end

  describe "#call", elasticsearch: true do
    it 'returns a valid search object' do
      query = new_query
      expect(results_count(query)).to eq 3
    end

    it 'searches by phrases' do
      query = new_query(term: 'Post 1')
      expect(results_count(query)).to eq 1
    end

    it 'filters by sectors' do
      # First check no response if filter not present
      query = new_query(sectors: ["medicine"])
      expect(results_count(query)).to eq 0

      # For opportunities from post, there will be a sector.
      # For opportunities from volumeops, there will not be a sector,
      # Therefore we look inside the text for volumeops

      # Finds one from Post, with a sector...
      expect(@post_1.source).to eq("post")
      test_sector = Sector.create(slug: "medicine", name: "medicine") 
      @post_1.sectors << test_sector
      expect(results_count(query)).to eq 1

      # Does not find one from VolumeOps (without sector)
      test_sector.destroy
      @post_1.update(source: 1)
      refresh_elasticsearch
      expect(results_count(query)).to eq 0

      # ... Unless the title matches
      @post_1.update(title: "medicine")
      expect(results_count(query)).to eq 1
    end

    it 'filters by countries' do
      # First check no response if filter not present
      query = new_query(countries: ["countries-slug"])
      expect(results_count(query)).to eq 0

      # Then check finds correctly if filter present
      @post_1.countries << Country.create(slug: "countries-slug", name: "name") 
      expect(results_count(query)).to eq 1
    end

    it 'filters by types' do
      # First check no response if filter not present
      query = new_query(opportunity_types: ["type-slug"])
      expect(results_count(query)).to eq 0

      # Then check finds correctly if filter present
      @post_1.types << Type.create(slug: "type-slug", name: "name") 
      refresh_elasticsearch
      expect(results_count(query)).to eq 1
    end

    it 'filters by values' do
      # First check no response if filter not present
      query = new_query(values: ["values-slug"])
      expect(results_count(query)).to eq 0

      # Then check finds correctly if filter present
      @post_1.values << Value.create(slug: "values-slug", name: "name") 
      refresh_elasticsearch
      expect(results_count(query)).to eq 1
    end

    it 'filters by sources' do
      # First check no response if filter not present
      query = new_query(sources: ['volume_opps'])
      expect(results_count(query)).to eq 0

      # Then check finds correctly if filter present
      @post_1.update(source: 'volume_opps')
      refresh_elasticsearch
      expect(results_count(query)).to eq 1
    end

    it 'can show expired opportunities' do
      # Build query that returns non-expired opportunities only
      # All posts are unexpired to should return everything
      query = new_query(expired: false)
      expect(results_count(query)).to eq 3

      # Then expire a post - search will hide that post
      @post_1.update(response_due_on: 1.day.ago)
      refresh_elasticsearch
      expect(results_count(query)).to eq 2
      
      # Then create a query that returns expired AND non-expired opportunites
      # Expect all opportunities to be shown
      query = new_query(expired: true)
      expect(results_count(query)).to eq 3
    end

    it 'can show unpublished opportunities' do
      # Build a query that shows only published opportunities
      # All opportunities are published currently
      query = new_query(status: :published)
      expect(results_count(query)).to eq 3

      # Then change a post to draft
      @post_1.update(status: :draft)
      refresh_elasticsearch
      expect(results_count(query)).to eq 2

      # Then search for published AND unpublished
      query = new_query(status: nil)
      expect(results_count(query)).to eq 3
    end

    describe 'can sort' do
      it 'by newest' do
        refresh_elasticsearch
        sort = OpportunitySort.new(default_column: 'first_published_at',
                                   default_order: 'desc')
        query = new_query(sort: sort)
        results = Opportunity.__elasticsearch__.search(
          query: query[:query],
          sort:  query[:sort]
        ).results
        expect(results[0].title).to eq "Post 3"
        expect(results[-1].title).to eq "Post 2"
      end
      it 'by soonest to close' do
        refresh_elasticsearch
        sort = OpportunitySort.new(default_column: 'response_due_on',
                                   default_order: 'asc')
        query = new_query(sort: sort)
        results = Opportunity.__elasticsearch__.search(
          query: query[:query],
          sort:  query[:sort]
        ).results
        expect(results[0].title).to eq "Post 1"
        expect(results[-1].title).to eq "Post 2"
      end
    end
  end

end
