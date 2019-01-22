require 'rails_helper'

RSpec.describe SubscriptionForm, focus: true do
  include RegionHelper
  let(:region_helper) { TestRegionHelper.new }
  class TestRegionHelper
    include RegionHelper
  end

  def search(params, total=nil)
    params = region_helper.region_and_country_param_conversion(params)
    Search.new(params).run
  end

  describe '#call' do
    it 'Returns subscription data object' do
      create(:country, slug: 'spain', name: "Spain")
      create(:country, slug: 'mexico', name: "Mexico")
      params = { s: 'food', countries: %w[spain mexico] }
      results = search(params)
      subscription = SubscriptionForm.new(results).call
      expect(subscription[:title]).to eq('food in Mexico or Spain').or eql('food in Spain or Mexico')
      expect(subscription[:keywords]).to eq('food')
      expect(subscription[:what]).to eq(' for food')
      expect(subscription[:where]).to eq(' in Mexico or Spain').or eq(' in Spain or Mexico')
    end
  end


  describe '#search_term' do
    it 'returns the query string' do
      params = { s: 'google' }
      results = search(params)
      expect(SubscriptionForm.new(results).search_term).to eq 'google'
    end

    context 'when a search term and single filters are provided' do
      it 'passes validation' do
        create(:country, slug: 'france')
        create(:sector, slug: 'industy')
        create(:type, slug: 'public')
        create(:value, slug: '10')
        params = {
          s: 'Industrial Lubricant',
          countries: %w[france],
          sectors: %w[industy],
          types: %w[public],
          values: %w[10],
        }

        results = search(params)
        form = SubscriptionForm.new(results)

        expect(form).to be_valid
        expect(form).to be_minimum_search_criteria
      end
    end

    context 'when a search term and multiple fitlers are provided' do
      it 'passes validation' do
        create(:country, slug: 'france')
        create(:country, slug: 'germany')
        create(:sector, slug: 'industy')
        create(:sector, slug: 'oils')
        create(:type, slug: 'public')
        create(:type, slug: 'private')
        create(:value, slug: '10')
        create(:value, slug: '100')
        create(:value, slug: '150')
        params = {
          s: 'Industial Lubricant',
          countries: %w[france germany],
          sectors: %w[industy oils],
          types: %w[public private],
          values: %w[10 100 150]
        }

        results = search(params)
        form = SubscriptionForm.new(results)

        expect(form).to be_valid
        expect(form).to be_minimum_search_criteria
      end
    end

    context 'when the search term is an empty string' do
      it 'fails validation' do
        params = { s: ' ' }
        results = search(params)
        form = SubscriptionForm.new(results)

        form.valid?

        expect(form).to be_minimum_search_criteria
      end

      it 'passes validation if a country filter is provided' do
        create(:country, slug: 'france')
        params = { s: '', countries: ['france'] }
        results = search(params)
        form = SubscriptionForm.new(results)

        expect(form).to be_valid
        expect(form).to be_minimum_search_criteria
      end

      it 'passes validation if a sector filter is provided' do
        create(:sector, slug: 'aerospace')
        params = { s: '', sectors: ['aerospace'] }
        results = search(params)
        form = SubscriptionForm.new(results)

        expect(form).to be_valid
        expect(form).to be_minimum_search_criteria
      end

      it 'passes validation if a type filter is provided' do
        create(:type, slug: 'public-sector')
        params = { s: '', types: ['public-sector'] }
        results = search(params)
        form = SubscriptionForm.new(results)

        expect(form).to be_valid
        expect(form).to be_minimum_search_criteria
      end

      it 'passes validation if a value filter is provided' do
        create(:value, slug: 'middle')
        params = { s: '', values: ['middle'] }
        results = search(params)

        form = SubscriptionForm.new(results)

        expect(form).to be_valid
        expect(form).to be_minimum_search_criteria
      end
    end

    context 'when the search term is empty' do
      it 'passes validation if a country filter is provided' do
        create(:country, slug: 'france')
        params = { s: '', countries: ['france'] }

        results = search(params)
        form = SubscriptionForm.new(results)

        expect(form).to be_valid
        expect(form).to be_minimum_search_criteria
      end

      it 'passes validation if a sector filter is provided' do
        create(:sector, slug: 'aerospace')
        params = { s: '', sectors: ['aerospace'] }

        results = search(params)
        form = SubscriptionForm.new(results)

        expect(form).to be_valid
        expect(form).to be_minimum_search_criteria
      end

      it 'passes validation if a type filter is provided' do
        create(:type, slug: 'public-sector')
        params = { s: '', types: ['public-sector'] }

        results = search(params)
        form = SubscriptionForm.new(results)

        expect(form).to be_valid
        expect(form).to be_minimum_search_criteria
      end

      it 'passes validation if a value filter is provided' do
        create(:value, slug: 'middle')
        params = { s: '', values: ['middle'] }

        results = search(params)
        form = SubscriptionForm.new(results)

        expect(form).to be_valid
        expect(form).to be_minimum_search_criteria
      end
    end
  end

  describe '#countries' do
    it 'returns an array of Country objects' do
      america = create(:country, slug: 'america')
      france = create(:country, slug: 'france')

      params = { countries: %w[america france] }
      results = search(params)
      expect(SubscriptionForm.new(results).countries).to eq [america, france]
    end

    it 'invalid when a country cannot be not found' do
      # Simulate SearchFilter NOT returning cleaned data
      allow_any_instance_of(SearchFilter).to receive(:countries).and_return(['dirty-data'])

      params = { countries: %w[america france] }
      results = search(params)
      subscription = SubscriptionForm.new(results)
      expect(subscription).not_to be_valid
      expect(subscription.errors.full_messages).to include('Countries cannot be found')
    end

    it "doesn't raise an error when query is nil" do
      expect { SubscriptionForm.new({}).countries }.to_not raise_error
    end
  end

  describe '#sectors' do
    it 'returns an array of Sector objects' do
      aerospace = create(:sector, slug: 'aerospace')
      fisheries = create(:sector, slug: 'fisheries')

      params = { sectors: %w[aerospace fisheries] }
      results = search(params)
      expect(SubscriptionForm.new(results).sectors).to eq [aerospace, fisheries]
    end

    it 'invalid when a sector cannot be not found' do
      # Simulate SearchFilter NOT returning cleaned data
      allow_any_instance_of(SearchFilter).to receive(:sectors).and_return(['dirty-data'])

      params = { sectors: %w[aerospace fisheries] }
      results = search(params)
      subscription = SubscriptionForm.new(results)
      expect(subscription).not_to be_valid
      expect(subscription.errors.full_messages).to include('Sectors cannot be found')
    end

    it "doesn't raise an error when query is nil" do
      expect { SubscriptionForm.new({}).sectors }.to_not raise_error
    end
  end

  describe '#types' do
    it 'returns an array of Type objects' do
      public_sector = create(:type, slug: 'public-sector')
      private_sector = create(:type, slug: 'private-sector')

      params = { types: ['public-sector', 'private-sector'] }
      results = search(params)
      expect(SubscriptionForm.new(results).types).to eq [public_sector, private_sector]
    end

    it 'invalid when a type cannot be found' do
      # Simulate SearchFilter NOT returning cleaned data
      allow_any_instance_of(SearchFilter).to receive(:types).and_return(['dirty-data'])

      params = { types: ['public-sector', 'private-sector'] }
      results = search(params)
      subscription = SubscriptionForm.new(results)
      expect(subscription).not_to be_valid
      expect(subscription.errors.full_messages).to include('Types cannot be found')
    end

    it "doesn't raise an error when query is nil" do
      expect { SubscriptionForm.new({}).types }.to_not raise_error
    end
  end

  describe '#values' do
    it 'returns an array of Value objects' do
      middle = create(:value, slug: 'middle')
      none = create(:value, slug: 'none')

      params = { values: %w[middle none] }
      results = search(params)
      expect(SubscriptionForm.new(results).values).to eq [middle, none]
    end

    it 'invalid when a value cannot be found' do
      # Simulate SearchFilter NOT returning cleaned data
      allow_any_instance_of(SearchFilter).to receive(:values).and_return(['dirty-data'])

      params = { values: %w[middle none] }
      results = search(params)
      subscription = SubscriptionForm.new(results)
      expect(subscription).not_to be_valid
      expect(subscription.errors.full_messages).to include('Values cannot be found')
    end

    it "doesn't raise an error when query is nil" do
      expect { SubscriptionForm.new({}).values }.to_not raise_error
    end
  end
end
