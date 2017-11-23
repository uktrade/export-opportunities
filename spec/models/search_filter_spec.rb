require 'rails_helper'

RSpec.describe SearchFilter, type: :service do
  describe '.sectors' do
    it 'only contains whitelisted sectors' do
      create(:sector, slug: 'airports')

      params = {
        sectors: %w[mind-control airports],
      }

      filters = SearchFilter.new(params)

      expect(filters.sectors).to include('airports')
      expect(filters.sectors).not_to include('mind-control')
    end
  end

  describe '.countries' do
    it 'only contains whitelisted countries' do
      create(:country, slug: 'australia')

      params = {
        countries: %w[australia hackistan],
      }

      filters = SearchFilter.new(params)

      expect(filters.countries).to include('australia')
      expect(filters.countries).not_to include('hackistan')
    end
  end

  describe '.types' do
    it 'only contains whitelisted types' do
      create(:type, slug: 'public-sector')

      params = {
        types: %w[evil-empire public-sector],
      }

      filters = SearchFilter.new(params)

      expect(filters.types).to include('public-sector')
      expect(filters.types).not_to include('evil-empire')
    end
  end

  describe '.values' do
    it 'only contains whitelisted values' do
      create(:value, slug: 'unknown')

      params = {
        values: %w[nothing unknown],
      }

      filters = SearchFilter.new(params)

      expect(filters.values).to include('unknown')
      expect(filters.values).not_to include('nothing')
    end
  end
end
