require 'rails_helper'

RSpec.describe OpportunitySearch, elasticsearch: true, focus: true do

  before do
    sector  = Sector.create(slug: 'test-sector', name: 'Sector 1')
    country = Country.create(slug: 'fiji', name: 'Fiji')
    10.times do |n|
      opportunity = create(:opportunity, title: "Title #{n}", slug: n.to_s,
                           response_due_on: (n + 1).weeks.from_now,
                           first_published_at: (n + 1).weeks.ago,
                           status: :publish,
                           source: n.even? ? :post : :volume_opps)
      opportunity.sectors   << sector     if n.between?(0,1)
      opportunity.countries << country   if n.between?(0,2)
      # opportunity.countries << @country_2 if n == 3
      opportunity.update(response_due_on: 1.day.from_now) if n == 4
      opportunity.update(first_published_at: 1.day.ago)   if n == 5
    end
    refresh_elasticsearch
  end

  it 'provides search results and total' do
    search = OpportunitySearch.new(term: 'Title')
    expect(search.results.count).to eq 10
    expect(search.total).to eq 10
  end
  it 'provides search results and total' do
    search = OpportunitySearch.new(term: 'Title 1')
    expect(search.total).to eq 1
  end
  describe "can sort" do
    it "by soonest to close" do
      sort = OpportunitySort.new(default_column: 'response_due_on',
                                 default_order: 'asc')
      search = OpportunitySearch.new(term: 'Title', sort: sort)
      expect(search.results[0].title).to eq "Title 4"
      expect(search.total).to eq 10
    end
    it "by most recently published" do
      sort = OpportunitySort.new(default_column: 'first_published_at',
                                 default_order: 'desc')
      search = OpportunitySearch.new(term: 'Title', sort: sort)
      expect(search.results[0].title).to eq "Title 5"
      expect(search.total).to eq 10
    end
  end
  describe "can filter" do
    it "by country" do
      filter = SearchFilter.new(countries: ['fiji'])
      search = OpportunitySearch.new(term: 'Title', filter: filter)
      expect(search.total).to eq 3
    end
    it "by industry" do
      filter = SearchFilter.new(sectors: ['test-sector'])
      search = OpportunitySearch.new(term: 'Title', filter: filter)
      expect(search.total).to eq 2
    end
    it "by sources" do
      filter = SearchFilter.new(sources: ['post'])
      search = OpportunitySearch.new(term: 'Title', filter: filter)
      expect(search.total).to eq 5
    end
  end
  it "can boost DIT post results" do
    # Only testing that it doesn't error
    search = OpportunitySearch.new(term: 'Title', boost: true)
    expect(search.results.count).to eq 10
    expect(search.total).to eq 10
  end
end
