require 'rails_helper'

RSpec.describe Opportunity do
  describe 'validations' do
    subject { FactoryBot.build(:opportunity) }
    it { is_expected.to validate_uniqueness_of(:slug).case_insensitive }
    it { is_expected.to have_many(:comments).class_name('OpportunityComment') }

    it 'has to have a title' do
      expect(Opportunity.new).to have(1).error_on(:title)
    end

    it 'has to have a teaser' do
      expect(Opportunity.new(source: :post)).to have(1).error_on(:teaser)
    end

    it 'has to have a response_due_on' do
      expect(Opportunity.new).to have(1).error_on(:response_due_on)
    end

    it 'has to have two contacts' do
      expect(Opportunity.new(source: :post)).to have(1).error_on(:contacts)
    end

    context 'when the contacts are valid' do
      it 'is valid' do
        valid_contact_details = [
          { name: 'Bob', email: 'bob@example.com' },
          { name: 'Mary', email: 'mary@example.com' },
        ]

        opportunity = Opportunity.new(contacts_attributes: valid_contact_details, source: :post)
        opportunity.valid?

        expect(opportunity).to have(0).error_on(:contacts)
      end
    end

    context 'when the contacts are invalid' do
      it 'is invalid' do
        invalid_contact_details = [
          { name: 'Bob', email: '07123456789' },
          { name: '', email: 'mary@example.com' },
        ]

        opportunity = Opportunity.new(contacts_attributes: invalid_contact_details, source: :post)
        opportunity.valid?

        expect(opportunity).to have(1).error_on(:"contacts.email")
        expect(opportunity).to have(1).error_on(:"contacts.name")
      end

      it 'does not count empty contacts towards the minimum contacts requirement' do
        opportunity = Opportunity.new(source: :post, contacts_attributes: Array.new(Opportunity::CONTACTS_PER_OPPORTUNITY, {}))
        expect(opportunity).to have(1).error_on(:contacts)
      end
    end
  end

  describe 'applicable scope' do
    it 'should only find current opportunities' do
      past_due = create(:opportunity, response_due_on: 1.day.ago)
      due_today = create(:opportunity, response_due_on: Time.zone.today)
      due_future = create(:opportunity, response_due_on: 3.months.from_now)

      expect(Opportunity.applicable).to include(due_today)
      expect(Opportunity.applicable).to include(due_future)
      expect(Opportunity.applicable).to_not include(past_due)
    end
  end

  describe 'deletion' do
    it 'deletes its associated contacts' do
      opportunity = create(:opportunity)
      contacts = opportunity.contacts

      opportunity.destroy

      expect(contacts).to all(be_destroyed)
    end
  end

  describe 'versioning' do
    it 'records changes to its status field' do
      opportunity = create(:opportunity, status: :pending)
      opportunity.status = :publish
      opportunity.save

      expect(opportunity.versions.last).not_to be_nil
      expect(opportunity.versions.last.changeset['status']).to eq %w[pending publish]
    end
  end

  describe '#expired?' do
    it 'returns true when the opportunity has expired' do
      opportunity = create(:opportunity, response_due_on: 1.day.ago)
      expect(opportunity).to be_expired
    end

    it 'returns false when the opportunity expires today' do
      opportunity = create(:opportunity, response_due_on: Time.zone.today)
      expect(opportunity).not_to be_expired
    end

    it 'returns false when the opportunity has yet to expire' do
      opportunity = create(:opportunity, response_due_on: 1.day.from_now)
      expect(opportunity).not_to be_expired
    end
  end

  describe '#as_indexed_json' do
    it 'returns only the keys we want' do
      require 'set'

      opportunity = create(:opportunity)
      opportunity.sectors = create_list(:sector, 2)
      opportunity.countries = create_list(:country, 2)
      opportunity.types = create_list(:type, 2)
      opportunity.values = [create(:value)]

      returned = opportunity.as_indexed_json

      permitted_keys = Set.new %w[title teaser description countries sectors types values created_at updated_at status response_due_on first_published_at source]
      returned_keys = Set.new(returned.keys)

      expect(permitted_keys).to eq returned_keys
    end
  end

  describe '#public_search' do
    before(:each) do
      @sort = OpportunitySort.new(default_column: 'first_published_at',
                                  default_order: 'desc')
      @post_1 = create(:opportunity, title: 'Post 1', first_published_at: 1.months.ago,
                        response_due_on: 12.months.from_now, status: :publish)
      @post_2 = create(:opportunity, title: 'Post 2', first_published_at: 2.months.ago,
                        response_due_on: 6.months.from_now, status: :publish)
      @post_3 = create(:opportunity, title: 'Post 3', first_published_at: 3.month.ago,
                       response_due_on: 18.months.from_now, status: :publish)
      Opportunity.__elasticsearch__.create_index! force: true
      refresh_elasticsearch
    end
    it 'provides a valid set of results' do
      search = Opportunity.public_search(sort: @sort)
      expect(search.results.count).to eq 3
    end
    it 'can search by a term' do
      search = Opportunity.public_search(search_term: 'Post 1',
                                         sort: @sort)
      expect(search.results.count).to eq 1
    end
    describe 'can filter' do
       it 'by countries' do
          @post_1.countries << Country.create(slug: 'country-slug', name: 'name')
          refresh_elasticsearch
          filter = SearchFilter.new(countries: ['country-slug'])
          search = Opportunity.public_search(filters: filter,
                                             sort:   @sort)
          expect(search.results.count).to eq 1
        end
       it 'by sectors' do
          @post_1.sectors << Sector.create(slug: 'sector-slug', name: 'name')
          refresh_elasticsearch
          filter = SearchFilter.new(sectors: ['sector-slug'])
          search = Opportunity.public_search(filters: filter,
                                             sort:   @sort)
          expect(search.results.count).to eq 1
       end
    end
    it 'can limit number of results' do
      10.times do |n|
        create(:opportunity, title: "Post #{n+3}", created_at: 2.months.ago,
                response_due_on: 12.months.from_now, status: :publish)
      end
      refresh_elasticsearch

      limit = 2
      search = Opportunity.public_search(limit: limit,
                                         sort:  @sort)

      # ElasticSearch returns 1 result per shard, and currently 5 shards.
      # Note, may return less than max due to data being unevenly 
      # spread across shards, thus some shards returning less than max
      max_number_to_find = limit * number_of_shards

      expect(Opportunity.count).to be > max_number_to_find
      expect(search.results.count).to be <= max_number_to_find
    end
    describe 'sorts results' do
      it 'by first_published_at' do
        # Note Post 1 was published most recently,
        #      Post 2 second most recently,
        #      Post 3 second least recently
        most_recently_first = 
          OpportunitySort.new(default_column: 'first_published_at',
                              default_order: 'desc')
        search = Opportunity.public_search(sort: most_recently_first)
        expect(search.records.first).to eq @post_1
        expect(search.records[-1]).to eq @post_3

        most_recently_last = 
          OpportunitySort.new(default_column: 'first_published_at',
                              default_order: 'asc')
        search = Opportunity.public_search(sort: most_recently_last)
        expect(search.records.first).to eq @post_3
        expect(search.records[-1]).to eq @post_1
      end
      it 'by response_due_on' do
        # Note Post 2 is due soonest,
        #      Post 1 second soonest,
        #      Post 3 least soon
        end_soonest_first = 
          OpportunitySort.new(default_column: 'response_due_on',
                              default_order: 'asc')
        search = Opportunity.public_search(sort: end_soonest_first)
        expect(search.records.first).to eq @post_2
        expect(search.records[-1]).to eq @post_3

        end_soonest_last = 
          OpportunitySort.new(default_column: 'response_due_on',
                              default_order: 'desc')
        search = Opportunity.public_search(sort: end_soonest_last)
        expect(search.records.first).to eq @post_3
        expect(search.records[-1]).to eq @post_2
      end
    end
  end

  describe '#public_featured_industries_search', focus: true do
    before(:each) do
      @post_1 = create(:opportunity, title: 'Post 1', first_published_at: 1.months.ago,
                        response_due_on: 12.months.from_now, status: :publish, source: 'post')
      @post_2 = create(:opportunity, title: 'Post 2', first_published_at: 2.months.ago,
                        response_due_on: 6.months.from_now, status: :publish, source: 'post')
      @post_3 = create(:opportunity, title: 'Post 3', first_published_at: 3.month.ago,
                       response_due_on: 18.months.from_now, status: :publish, source: 'post')
      @sector_slug = 'sector-slug'
      s = Sector.create(slug: @sector_slug, name: 'name')
      @post_1.sectors << s
      @post_2.sectors << s
      @post_3.sectors << s
      @sources = SearchFilter.new.sources
      @sort = OpportunitySort.new(default_column: 'first_published_at',
                                  default_order: 'desc')
      Opportunity.__elasticsearch__.create_index! force: true
      refresh_elasticsearch
    end
    it 'provides a valid set of results' do
      search = Opportunity.public_featured_industries_search(@sector_slug, '', @sources, @sort)
      expect(search.results.count).to eq 3
    end
    it 'filters by industry' do
      @post_1.sectors << Sector.create(slug: 'new-sector', name: 'name')
      refresh_elasticsearch
      search = Opportunity.public_featured_industries_search('new-sector', '', @sources, @sort)
      expect(search.results.count).to eq 1
    end
    it 'sources correctly - but needs a search query for volume opps (tested: only post, only volume_opps, all)' do
      @post_1.update(source: 'volume_opps')
      refresh_elasticsearch

      # Only post
      post_source = SearchFilter.new(sources: 'post').sources
      search = Opportunity.public_featured_industries_search(@sector_slug, '', post_source, @sort)
      expect(search.results.count).to eq 2

      # Only volume opps AND has a search query
      volume_opps_source = SearchFilter.new(sources: 'volume_opps').sources
      search = Opportunity.public_featured_industries_search(@sector_slug, 'Post', volume_opps_source, @sort)
      expect(search.results.count).to eq 1

      # All
      search = Opportunity.public_featured_industries_search(@sector_slug, 'Post', @sources, @sort)
      expect(search.results.count).to eq 3
    end
    describe 'sorts results' do
      it 'by first_published_at' do
        # # Note Post 1 was published most recently,
        # #      Post 2 second most recently,
        # #      Post 3 second least recently
        # most_recently_first = 
        #   OpportunitySort.new(default_column: 'first_published_at',
        #                       default_order: 'desc')
        # search = Opportunity.public_search(sort: most_recently_first)
        # expect(search.records.first).to eq @post_1
        # expect(search.records[-1]).to eq @post_3
# 
        # most_recently_last = 
        #   OpportunitySort.new(default_column: 'first_published_at',
        #                       default_order: 'asc')
        # search = Opportunity.public_search(sort: most_recently_last)
        # expect(search.records.first).to eq @post_3
        # expect(search.records[-1]).to eq @post_1
      end
      it 'by response_due_on' do
        # # Note Post 2 is due soonest,
        # #      Post 1 second soonest,
        # #      Post 3 least soon
        # end_soonest_first = 
        #   OpportunitySort.new(default_column: 'response_due_on',
        #                       default_order: 'asc')
        # search = Opportunity.public_search(sort: end_soonest_first)
        # expect(search.records.first).to eq @post_2
        # expect(search.records[-1]).to eq @post_3

        # end_soonest_last = 
        #   OpportunitySort.new(default_column: 'response_due_on',
        #                       default_order: 'desc')
        # search = Opportunity.public_search(sort: end_soonest_last)
        # expect(search.records.first).to eq @post_3
        # expect(search.records[-1]).to eq @post_2
      end
    end
  end
end
