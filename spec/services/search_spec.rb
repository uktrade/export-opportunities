require 'rails_helper'

RSpec.describe Search, elasticsearch: true do

  describe 'cleans input parameters and' do
    it "allows only valid seach terms" do
      search = Search.new({})
      expect(search.term).to eq ""

      search = Search.new({ s: 'Title é 0' })
      expect(search.term).to eq "Title 0"
    end
    it "allows only valid filters" do
      search = Search.new({ regions: %w[western-europe invalid-country] })
      filter = search.filter
      expect(filter.regions).to eq ["western-europe"]

      search = Search.new({ regions: %w[western-europe invalid-country] })
      filter = search.filter
      expect(filter.regions).to include "western-europe"

      create(:sector, slug: 'airports')
      create(:sector, slug: 'stations')
      params = { sectors: %w[airports stations invalid] }
      search = Search.new(params)
      filter = search.filter
      expect(filter.sectors).to include("airports")
      expect(filter.sectors).to include("stations")
      expect(filter.sectors).not_to include("invalid")
    end
    it "allows only valid sort" do
      search = Search.new({ sort_column_name: 'response_due_on' })
      sort = search.instance_variable_get(:@sort)
      expect(sort.column).to eq "response_due_on"
      expect(sort.order).to eq "asc"

      search = Search.new({ sort_column_name: 'first_published_at' })
      sort = search.instance_variable_get(:@sort)
      expect(sort.column).to eq "first_published_at"
      expect(sort.order).to eq "desc"

      search = Search.new({ sort_column_name: 'updated_at' })
      sort = search.instance_variable_get(:@sort)
      expect(sort.column).to eq "updated_at"
      expect(sort.order).to eq "desc"

      search = Search.new({ sort_column_name: 'invalid' })
      sort = search.instance_variable_get(:@sort)
      expect(sort.column).to eq "response_due_on"
      expect(sort.order).to eq "asc"

      search = Search.new({})
      sort = search.instance_variable_get(:@sort)
      expect(sort.column).to eq "response_due_on"
      expect(sort.order).to eq "asc"
    end
    it "allows only valid boost" do
      search = Search.new({ 'boost_search' => 'y' })
      boost = search.instance_variable_get(:@boost)
      expect(boost).to be_truthy

      search = Search.new({})
      boost = search.instance_variable_get(:@boost)
      expect(boost).not_to be_truthy
    end
  end

  describe '#run' do

    before do
      Opportunity.destroy_all
      @sort = OpportunitySort.new(default_column: 'first_published_at',
                                  default_order: 'desc')
      @post_1 = create(:opportunity, title: 'Post 1', first_published_at: 1.months.ago,
                        response_due_on: 12.months.from_now, status: :publish,
                       updated_at: 3.month.ago)
      @post_2 = create(:opportunity, title: 'Post 2', first_published_at: 2.months.ago,
                        response_due_on: 6.months.from_now, status: :publish,
                       updated_at: 2.month.ago)
      @post_3 = create(:opportunity, title: 'Post 3', first_published_at: 3.month.ago,
                       response_due_on: 18.months.from_now, status: :publish,
                       updated_at: 1.month.ago)
      @post_1.countries << Country.create(slug: 'country-slug', name: 'Country 1')
      sector = Sector.create(slug: 'sector-slug', name: 'Sector 1')
      @post_1.sectors << sector
      @post_2.sectors << sector
      Opportunity.__elasticsearch__.create_index! force: true
      refresh_elasticsearch
    end
    
    it 'provides a valid set of results' do
      results = Search.new({}).run
      expect(results[:total]).to eq 3
    end
    it 'can search by a term' do
      results = Search.new({ s: 'Post 1' }).run
      expect(results[:total]).to eq 1
    end
    describe 'can filter' do
      it 'by countries' do
        results = Search.new({ countries: ['country-slug'] }).run
        expect(results[:total]).to eq 1
       end
      it 'by sectors' do
        filter = SearchFilter.new(sectors: ['sector-slug'])
        results = Search.new({ sectors: ['sector-slug'] }).run

        expect(results[:total]).to eq 2
      end
    end
    describe 'sorts results' do
      it 'by first_published_at' do
        # Note Post 1 was published most recently,
        #      Post 2 second most recently,
        #      Post 3 second least recently
        results = Search.new({ sort_column_name: 'first_published_at' }).run
        expect(results[:results][0]).to eq @post_1
        expect(results[:results][-1]).to eq @post_3
      end
      it 'by response_due_on' do
        # Note Post 2 is due soonest,
        #      Post 1 second soonest,
        #      Post 3 least soon
        results = Search.new({ sort_column_name: 'response_due_on' }).run
        expect(results[:results][0]).to eq @post_2
        expect(results[:results][-1]).to eq @post_3
      end
      it 'by updated_at' do
        results = Search.new({ sort_column_name: 'updated_at' }).run
        expect(results[:results][0]).to eq @post_3
        expect(results[:results][-1]).to eq @post_1
      end
    end
  end
end
