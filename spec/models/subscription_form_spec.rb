require 'rails_helper'

RSpec.describe SubscriptionForm do
  describe '#search_term' do
    it 'returns the query string' do
      params = { query: { search_term: 'google' } }
      expect(SubscriptionForm.new(params).search_term).to eq 'google'
    end

    context 'when a search term and single filters are provided' do
      it 'passes validation' do
        create(:country, slug: 'france')
        create(:sector, slug: 'industy')
        create(:type, slug: 'public')
        create(:value, slug: '10')
        params = {
          query: {
            search_term: 'Industrial Lubricant',
            countries: %w(france),
            sectors: %w(industy),
            types: %w(public),
            value: %w(10),
          },
        }

        form = SubscriptionForm.new(params)

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
          query: {
            search_term: 'Industial Lubricant',
            countries: %w(france germany),
            sectors: %w(industy oils),
            types: %w(public private),
            value: %w(10 100 150),
          },
        }

        form = SubscriptionForm.new(params)

        expect(form).to be_valid
        expect(form).to be_minimum_search_criteria
      end
    end

    context 'when the search term is an empty string' do
      it 'fails validation' do
        params = { query: { search_term: ' ' } }
        form = SubscriptionForm.new(params)

        form.valid?

        expect(form.errors.messages.keys).to include(:base)
        expect(form).not_to be_minimum_search_criteria
      end

      it 'passes validation if a country filter is provided' do
        create(:country, slug: 'france')
        params = {
          query: {
            search_term: '',
            countries: ['france'],
          },
        }

        form = SubscriptionForm.new(params)

        expect(form).to be_valid
        expect(form).to be_minimum_search_criteria
      end

      it 'passes validation if a sector filter is provided' do
        create(:sector, slug: 'aerospace')
        params = {
          query: {
            search_term: '',
            sectors: ['aerospace'],
          },
        }

        form = SubscriptionForm.new(params)

        expect(form).to be_valid
        expect(form).to be_minimum_search_criteria
      end

      it 'passes validation if a type filter is provided' do
        create(:type, slug: 'public-sector')
        params = {
          query: {
            search_term: '',
            types: ['public-sector'],
          },
        }

        form = SubscriptionForm.new(params)

        expect(form).to be_valid
        expect(form).to be_minimum_search_criteria
      end

      it 'passes validation if a value filter is provided' do
        create(:value, slug: 'middle')
        params = {
          query: {
            search_term: '',
            values: ['middle'],
          },
        }

        form = SubscriptionForm.new(params)

        expect(form).to be_valid
        expect(form).to be_minimum_search_criteria
      end
    end

    context 'when the search term is nil' do
      it 'fails validation' do
        params = { query: { search_term: nil } }
        form = SubscriptionForm.new(params)

        form.valid?

        expect(form.errors.messages.keys).to include(:base)
        expect(form).not_to be_minimum_search_criteria
      end

      it 'passes validation if a country filter is provided' do
        create(:country, slug: 'france')
        params = {
          query: {
            search_term: nil,
            countries: ['france'],
          },
        }

        form = SubscriptionForm.new(params)

        expect(form).to be_valid
        expect(form).to be_minimum_search_criteria
      end

      it 'passes validation if a sector filter is provided' do
        create(:sector, slug: 'aerospace')
        params = {
          query: {
            search_term: nil,
            sectors: ['aerospace'],
          },
        }

        form = SubscriptionForm.new(params)

        expect(form).to be_valid
        expect(form).to be_minimum_search_criteria
      end

      it 'passes validation if a type filter is provided' do
        create(:type, slug: 'public-sector')
        params = {
          query: {
            search_term: nil,
            types: ['public-sector'],
          },
        }

        form = SubscriptionForm.new(params)

        expect(form).to be_valid
        expect(form).to be_minimum_search_criteria
      end

      it 'passes validation if a value filter is provided' do
        create(:value, slug: 'middle')
        params = {
          query: {
            search_term: nil,
            values: ['middle'],
          },
        }

        form = SubscriptionForm.new(params)

        expect(form).to be_valid
        expect(form).to be_minimum_search_criteria
      end
    end
  end

  describe '#countries' do
    it 'returns an array of Country objects' do
      america = create(:country, slug: 'america')
      france = create(:country, slug: 'france')

      params = { query: { countries: %w(america france) } }
      expect(SubscriptionForm.new(params).countries).to eq [america, france]
    end

    it 'invalid when a country cannot be not found' do
      params = { query: { countries: %w(america france) } }
      subscription = SubscriptionForm.new(params)
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

      params = { query: { sectors: %w(aerospace fisheries) } }
      expect(SubscriptionForm.new(params).sectors).to eq [aerospace, fisheries]
    end

    it 'invalid when a sector cannot be not found' do
      params = { query: { sectors: %w(aerospace fisheries) } }
      subscription = SubscriptionForm.new(params)
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

      params = { query: { types: ['public-sector', 'private-sector'] } }
      expect(SubscriptionForm.new(params).types).to eq [public_sector, private_sector]
    end

    it 'invalid when a type cannot be found' do
      params = { query: { types: ['public-sector', 'private-sector'] } }
      subscription = SubscriptionForm.new(params)
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

      params = { query: { values: %w(middle none) } }
      expect(SubscriptionForm.new(params).values).to eq [middle, none]
    end

    it 'invalid when a value cannot be found' do
      params = { query: { values: %w(middle none) } }
      subscription = SubscriptionForm.new(params)
      expect(subscription).not_to be_valid
      expect(subscription.errors.full_messages).to include('Values cannot be found')
    end

    it "doesn't raise an error when query is nil" do
      expect { SubscriptionForm.new({}).values }.to_not raise_error
    end
  end
end
