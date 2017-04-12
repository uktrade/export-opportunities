require 'rails_helper'

RSpec.describe OpportunityQuery do
  describe '#opportunities' do
    it 'returns an opportunity query object' do
      opportunity = create(:opportunity, title: 'foo', status: 2)

      response = OpportunityQuery.new(search_term: 'foo', sort: fake_sort).opportunities

      expect(response).to be_kind_of(ActiveRecord::Relation)
      expect(response.first).to eq(opportunity)
    end

    context 'when called without parameters (default behaviour)' do
      it 'does not filter out opportunities based on a search' do
        expect(Opportunity).not_to receive(:fuzzy_match)
        OpportunityQuery.new(sort: fake_sort).opportunities
      end

      it 'returns all opportunities irrespective of status and expiry' do
        create(:opportunity, status: :publish)
        create(:opportunity, status: :pending)
        create(:opportunity, status: :trash)

        create(:opportunity, :expired, status: :publish)
        create(:opportunity, :expired, status: :pending)
        create(:opportunity, :expired, status: :trash)

        result = OpportunityQuery.new(sort: fake_sort).opportunities
        expect(result.size).to eq(6)
      end
    end

    it 'returns no expired opps when hide_expired is true' do
      create(:opportunity, :expired)
      selected = create(:opportunity)

      result = OpportunityQuery.new(hide_expired: true, sort: fake_sort).opportunities
      expect(result.size).to eq(1)
      expect(result.first.id).to eq selected.id
    end

    context 'when a status is provided' do
      it 'filters accordingly' do
        create(:opportunity, status: 'pending')
        create(:opportunity, status: 'pending')
        published_opportunity = create(:opportunity, status: 'publish')

        result = OpportunityQuery.new(status: 'pending', sort: fake_sort).opportunities
        expect(result.size).to eq(2)
        expect(result).not_to include(published_opportunity)
      end
    end

    context 'when a search term is provided' do
      it 'returns only opportunities that include that string in the title, teaser and description' do
        create(:opportunity, status: 'publish', title: 'Pikachu')
        create(:opportunity, status: 'publish', teaser: 'Catch us a Pikachu!')
        create(:opportunity, status: 'publish', description: 'We need more Pikachu.')
        create(:opportunity)

        result = OpportunityQuery.new(search_term: 'pikachu', sort: fake_sort).opportunities
        expect(result.size).to eq(3)
      end

      it 'returns opportunities by relevance' do
        create(:opportunity, :published, title: 'Pikachu Pikachu Pikachu', created_at: 2.months.ago)
        create(:opportunity, :published, title: 'Only one Pikachu', created_at: 1.month.ago)

        result = OpportunityQuery.new(search_term: 'pikachu', sort: fake_sort, ignore_sort: true).opportunities

        expect(result[0].title).to eq('Pikachu Pikachu Pikachu')
        expect(result[1].title).to eq('Only one Pikachu')
      end
    end

    context 'when a sort is provided' do
      it 'returns opportunities sorted in that order' do
        create(:opportunity, status: 'publish', title: 'Abra')
        create(:opportunity, status: 'publish', title: 'Bayleef')
        create(:opportunity, status: 'publish', title: 'Charmander')

        sorter = OpenStruct.new(column: 'title', order: 'asc')
        result = OpportunityQuery.new(sort: sorter).opportunities
        expect(result[0].title).to eq('Abra')
        expect(result[1].title).to eq('Bayleef')
        expect(result[2].title).to eq('Charmander')
      end
    end

    context 'when a search term is provided' do
      it 'will use a default fuzzy_match to return opportunities' do
        expect(Opportunity).to receive(:fuzzy_match)
        OpportunityQuery.new(search_term: 'Diglett', sort: fake_sort).opportunities
      end

      context 'when a pg_search search method is provided' do
        it 'will use that search to return opportunities' do
          expect(Opportunity).to receive(:admin_match).and_return(nil)
          OpportunityQuery.new(search_term: 'Crobat', search_method: :admin_match, sort: fake_sort).opportunities
        end

        it 'will throw an error if you send a non-existent search_method' do
          expect do
            OpportunityQuery.new(search_term: 'Durant', search_method: :non_existent_match, sort: fake_sort).opportunities
          end.to raise_error(NoMethodError)
        end
      end
    end

    context 'when filters are provided' do
      it 'returns an opportunity only once, even though it matches multiple filters in different categories' do
        pet_food = create(:sector, name: 'Pet food', slug: 'pet-food')
        albania = create(:country, name: 'USA', slug: 'usa')
        million_pounds = create(:value, name: '1 Million Pounds', slug: '1million')
        create(:opportunity, title: 'America wants pet food', status: 'publish', sectors: [pet_food], countries: [albania], values: [million_pounds])

        filters = OpenStruct.new(sectors: ['pet-food'], countries: ['usa'], value: ['1million'])
        results = OpportunityQuery.new(filters: filters, sort: fake_sort).opportunities

        expect(results.count).to eq 1
      end

      it 'returns an opportunity only once, even though it matches multiple filters' do
        pet_food = create(:sector, name: 'Pet food', slug: 'pet-food')
        stationery = create(:sector, name: 'Stationery', slug: 'stationery')
        create(:opportunity, title: 'Edible cat pencils', status: 'publish', sectors: [pet_food, stationery])

        filters = OpenStruct.new(sectors: ['pet-food', 'stationery'])
        results = OpportunityQuery.new(filters: filters, sort: fake_sort).opportunities

        expect(results.count).to eq 1
      end

      it 'removes opportunities where they have unmatched relations' do
        sector = create(:sector, slug: 'bar')
        country = create(:country, slug: 'haz')
        type = create(:type, slug: 'baz')
        value = create(:value, slug: 'faz')

        matching_opportunity = create(:opportunity, title: 'foo', status: 2,
                                                    sectors: [sector], countries: [country], types: [type], values: [value])
        unmatching_opportunity = create(:opportunity, title: 'foo', status: 2)

        filters = OpenStruct.new(
          sectors: ['bar'],
          countries: ['haz'],
          types: ['baz'],
          values: ['faz']
        )

        response = OpportunityQuery.new(search_term: 'foo', filters: filters, sort: fake_sort).opportunities

        expect(response).to include(matching_opportunity)
        expect(response).not_to include(unmatching_opportunity)
      end
    end
  end

  def fake_sort
    OpenStruct.new(column: 'created_at', order: 'desc')
  end
end
