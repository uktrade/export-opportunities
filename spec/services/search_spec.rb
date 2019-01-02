require 'rails_helper'

RSpec.describe Search, elasticsearch: true do

  describe '#public_search' do
    before do
      Opportunity.destroy_all
      @sort = OpportunitySort.new(default_column: 'first_published_at',
                                  default_order: 'desc')
      @post_1 = create(:opportunity, title: 'Post 1', first_published_at: 1.months.ago,
                        response_due_on: 12.months.from_now, status: :publish)
      @post_2 = create(:opportunity, title: 'Post 2', first_published_at: 2.months.ago,
                        response_due_on: 6.months.from_now, status: :publish)
      @post_3 = create(:opportunity, title: 'Post 3', first_published_at: 3.month.ago,
                       response_due_on: 18.months.from_now, status: :publish)
      @post_1.countries << Country.create(slug: 'country-slug', name: 'Country 1')
      sector = Sector.create(slug: 'sector-slug', name: 'Sector 1')
      @post_1.sectors << sector
      @post_2.sectors << sector
      Opportunity.__elasticsearch__.create_index! force: true
      refresh_elasticsearch
    end
    it 'provides a valid set of results' do
      search = Search.new({ sort: @sort }).public_search
      expect(search[:search].results.count).to eq 3
    end
    it 'can search by a term' do
      search = Search.new({ term: 'Post 1', sort: @sort }).public_search
      expect(search[:search].results.count).to eq 1
    end
    describe 'can filter' do
      it 'by countries' do
        filter = SearchFilter.new(countries: ['country-slug'])
        search = Search.new({ filter: filter, sort: @sort }).public_search

        expect(search[:search].results.count).to eq 1
       end
      it 'by sectors' do
        filter = SearchFilter.new(sectors: ['sector-slug'])
        search = Search.new({ filter: filter, sort: @sort }).public_search

        expect(search[:search].results.count).to eq 2
      end
    end
    it 'can limit number of results and fetch the total_without_limit' do
      12.times do |n|
        create(:opportunity, title: "Post #{n+3}", created_at: 2.months.ago,
                response_due_on: 12.months.from_now, status: :publish)
      end
      refresh_elasticsearch

      limit = 2
      search = Search.new({ sort: @sort }, limit: limit).public_search

      # ElasticSearch returns 1 result per shard, and currently 5 shards.
      # Note, may return less than max due to data being unevenly 
      # spread across shards, thus some shards returning less than max
      max_number_to_find = limit * number_of_shards

      expect(Opportunity.count).to be > max_number_to_find
      expect(search[:search].results.count).to be <= max_number_to_find
      expect(search[:total_without_limit]).to eq 15
    end
    describe 'sorts results' do
      it 'by first_published_at' do
        # Note Post 1 was published most recently,
        #      Post 2 second most recently,
        #      Post 3 second least recently
        newest_first = 
          OpportunitySort.new(default_column: 'first_published_at',
                              default_order: 'desc')
        search = Search.new({ sort: newest_first }).public_search
        expect(search[:search].records.first).to eq @post_1
        expect(search[:search].records[-1]).to eq @post_3

        newest_last = 
          OpportunitySort.new(default_column: 'first_published_at',
                              default_order: 'asc')
        search = Search.new({ sort: newest_last }).public_search
        expect(search[:search].records.first).to eq @post_3
        expect(search[:search].records[-1]).to eq @post_1
      end
      it 'by response_due_on' do
        # Note Post 2 is due soonest,
        #      Post 1 second soonest,
        #      Post 3 least soon
        end_soonest_first = 
          OpportunitySort.new(default_column: 'response_due_on',
                              default_order: 'asc')
        search = Search.new({ sort: end_soonest_first }).public_search
        expect(search[:search].records.first).to eq @post_2
        expect(search[:search].records[-1]).to eq @post_3

        end_soonest_last = 
          OpportunitySort.new(default_column: 'response_due_on',
                              default_order: 'desc')
        search = Search.new({ sort: end_soonest_last }).public_search
        expect(search[:search].records.first).to eq @post_3
        expect(search[:search].records[-1]).to eq @post_2
      end
    end
  end

  describe '#industries_search' do
    
    before do
      Opportunity.destroy_all
      @post_1 = create(:opportunity, title: 'Title 1', first_published_at: 1.months.ago,
                        response_due_on: 12.months.from_now, status: :publish, source: 'volume_opps')
      @post_2 = create(:opportunity, title: 'Title 2', first_published_at: 2.months.ago,
                        response_due_on: 6.months.from_now, status: :publish, source: 'post')
      @post_3 = create(:opportunity, title: 'Title 3', first_published_at: 3.month.ago,
                       response_due_on: 18.months.from_now, status: :publish, source: 'post')
      @sector   = Sector.create(slug: 'sector-slug', name: 'Sector 1')
      sector_2 = Sector.create(slug: 'new-sector', name: 'Sector 2')
      @post_1.sectors << @sector
      @post_2.sectors << @sector
      @post_3.sectors << @sector
      @post_1.sectors << sector_2
      @filter = SearchFilter.new(sectors: [@sector.slug]) 
      @sort = OpportunitySort.new(default_column: 'first_published_at',
                                  default_order: 'desc')
      Opportunity.__elasticsearch__.create_index! force: true
      refresh_elasticsearch
    end

    it 'provides a valid set of results' do
      search = Search.new({ term: 'Title', sort: @sort, filter: @filter }).
                 industries_search
      expect(search[:search].results.count).to eq 3
    end

    it 'filters by industry' do
      new_filter = SearchFilter.new(sectors: ['new-sector'])

      search = Search.new({ term: 'Title', sort: @sort, filter: new_filter }).
        industries_search

      expect(search[:search].results.count).to eq 1
    end

    it 'sources correctly - NOTE needs a search query for volume opps' do
      # tested: only post, only volume_opps, all

      # Only post
      post_filter = SearchFilter.new(sources: 'post', sectors: [@sector.slug])

      search = Search.new({ term: 'Title', sort: @sort, filter: post_filter }).
        industries_search

      expect(search[:search].results.count).to eq 2

      # Only volume opps AND has a search query
      volume_opps_filter = SearchFilter.new(sources: 'volume_opps', sectors: [@sector.slug])

      search = Search.new({ term: 'Title', sort: @sort, filter: volume_opps_filter }).
        industries_search

      expect(search[:search].results.count).to eq 1

      # All
      search = Search.new({ term: 'Title', sort: @sort, filter: @filter }).
        industries_search
      expect(search[:search].results.count).to eq 3
    end
    describe 'sorts results' do
      it 'by first_published_at' do
        # Note Post 1 was published most recently,
        #      Post 3 least recently
        most_recently_first = 
          OpportunitySort.new(default_column: 'first_published_at',
                              default_order: 'desc')
        search = Search.new({ term: 'Title',
                              sort: most_recently_first,
                              filter: @filter }).industries_search
        expect(search[:search].records.first).to eq @post_1
        expect(search[:search].records[-1]).to eq @post_3

        most_recently_last = 
          OpportunitySort.new(default_column: 'first_published_at',
                              default_order: 'asc')
        search = Search.new({ term: 'Title', sort: most_recently_last, filter: @filter }).
                 industries_search
        expect(search[:search].records.first).to eq @post_3
        expect(search[:search].records[-1]).to eq @post_1
      end
      it 'by response_due_on' do
        # Note Post 2 is due soonest,
        #      Post 3 least soon
        end_soonest_first = 
          OpportunitySort.new(default_column: 'response_due_on',
                              default_order: 'asc')
        search = Search.new({ term: 'Title', sort: end_soonest_first, filter: @filter }).
                 industries_search
        expect(search[:search].records.first).to eq @post_2
        expect(search[:search].records[-1]).to eq @post_3

        end_soonest_last = 
          OpportunitySort.new(default_column: 'response_due_on',
                              default_order: 'desc')
        search = Search.new({ term: 'Title', sort: end_soonest_last, filter: @filter }).
                 industries_search
        expect(search[:search].records.first).to eq @post_3
        expect(search[:search].records[-1]).to eq @post_2
      end
    end
  end
end

  # before do
  #   sector  = Sector.create(slug: 'test-sector', name: 'Sector 1')
  #   country = Country.create(slug: 'fiji', name: 'Fiji')
  #   10.times do |n|
  #     opportunity = create(:opportunity, title: "Title #{n}", slug: n.to_s,
  #                          response_due_on: (n + 1).weeks.from_now,
  #                          first_published_at: (n + 1).weeks.ago,
  #                          status: :publish,
  #                          source: n.even? ? :post : :volume_opps)
  #     opportunity.sectors   << sector     if n.between?(0,1)
  #     opportunity.countries << country   if n.between?(0,2)
  #     # opportunity.countries << @country_2 if n == 3
  #     opportunity.update(response_due_on: 1.day.from_now) if n == 4
  #     opportunity.update(first_published_at: 1.day.ago)   if n == 5
  #   end
  #   refresh_elasticsearch
  # end

  # it 'provides search results and total' do
  #   search = Search.new({ term: 'Title' }).call
  #   expect(search.results.count).to eq 10
  #   expect(search.total).to eq 10
  # end
  # it 'provides search results and total' do
  #   search = Search.new({ term: 'Title 1' }).call
  #   expect(search.total).to eq 1
  # end
  # describe "can sort" do
  #   it "by soonest to close" do
  #     sort = OpportunitySort.new(default_column: 'response_due_on',
  #                                default_order: 'asc')
  #     search = Search.new({ term: 'Title', sort: sort }).call
  #     expect(search.results[0].title).to eq "Title 4"
  #     expect(search.total).to eq 10
  #   end
  #   it "by most recently published" do
  #     sort = OpportunitySort.new(default_column: 'first_published_at',
  #                                default_order: 'desc')
  #     search = Search.new({ term: 'Title', sort: sort }).call
  #     expect(search.results[0].title).to eq "Title 5"
  #     expect(search.total).to eq 10
  #   end
  # end
  # describe "can filter" do
  #   it "by country" do
  #     filter = SearchFilter.new(countries: ['fiji'])
  #     search = Search.new({ term: 'Title', filter: filter }).call
  #     expect(search.total).to eq 3
  #   end
  #   it "by industry" do
  #     filter = SearchFilter.new(sectors: ['test-sector'])
  #     search = Search.new({ term: 'Title', filter: filter }).call
  #     expect(search.total).to eq 2
  #   end
  #   it "by sources" do
  #     filter = SearchFilter.new(sources: ['post'])
  #     search = Search.new({ term: 'Title', filter: filter }).call
  #     expect(search.total).to eq 5
  #   end
  # end
  # it "can boost DIT post results" do
  #   # Only testing that it doesn't error
  #   search = Search.new({ term: 'Title', boost: true }).call
  #   expect(search.results.count).to eq 10
  #   expect(search.total).to eq 10
  # end
