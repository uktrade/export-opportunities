require 'rails_helper'

RSpec.describe SearchFilter, type: :service do
  describe '.sectors' do
    it 'only contains whitelisted sectors' do
      create(:sector, slug: 'airports')
      params = { sectors: %w[mind-control airports] }
      filters = SearchFilter.new(params)

      expect(filters.sectors).to include('airports')
      expect(filters.sectors).not_to include('mind-control')
    end

    it 'returns an empty array when no sector params' do
      params = {}
      filter = SearchFilter.new(params)

      expect(filter.sectors).to eq([])
    end

    it 'returns an array of sector slugs' do
      create(:sector, slug: 'airports')
      create(:sector, slug: 'stations')
      params = { sectors: %w[airports stations] }
      filter = SearchFilter.new(params)

      expect(filter.sectors.length).to eq(2)
      expect(filter.sectors).to include('airports')
      expect(filter.sectors).to include('stations')
    end
  end

  describe '.regions' do
    it 'only contains whitelisted regions' do
      params = { regions: %w[western-europe hackistan] }
      filter = SearchFilter.new(params)

      expect(filter.regions).to include('western-europe')
      expect(filter.regions).not_to include('hackistan')
    end

    it 'returns an empty array when no region params' do
      params = {}
      filter = SearchFilter.new(params)

      expect(filter.regions).to eq([])
    end

    it 'returns an array of region slugs' do
      create(:sector, slug: 'europe')
      create(:sector, slug: 'asia')
      params = { sectors: %w[europe asia] }
      filter = SearchFilter.new(params)

      expect(filter.sectors.length).to eq(2)
      expect(filter.sectors).to include('europe')
      expect(filter.sectors).to include('asia')
    end
  end

  describe '.countries' do
    it 'only contains whitelisted countries' do
      create(:country, slug: 'australia')
      params = { countries: %w[australia hackistan] }
      filters = SearchFilter.new(params)

      expect(filters.countries).to include('australia')
      expect(filters.countries).not_to include('hackistan')
    end

    it 'returns an empty array when no country params' do
      params = {}
      filter = SearchFilter.new(params)

      expect(filter.countries).to eq([])
    end

    it 'returns an array of country slugs' do
      create(:sector, slug: 'france')
      create(:sector, slug: 'spain')
      params = { sectors: %w[france spain] }
      filter = SearchFilter.new(params)

      expect(filter.sectors.length).to eq(2)
      expect(filter.sectors).to include('france')
      expect(filter.sectors).to include('spain')
    end
  end

  describe '.types' do
    it 'only contains whitelisted types' do
      create(:type, slug: 'public-sector')
      params = { types: %w[evil-empire public-sector] }
      filters = SearchFilter.new(params)

      expect(filters.types).to include('public-sector')
      expect(filters.types).not_to include('evil-empire')
    end

    it 'returns an empty array when no type params' do
      params = {}
      filter = SearchFilter.new(params)

      expect(filter.types).to eq([])
    end

    it 'returns an array of type slugs' do
      create(:sector, slug: 'public-sector')
      create(:sector, slug: 'private-sector')
      params = { sectors: %w[public-sector private-sector] }
      filter = SearchFilter.new(params)

      expect(filter.sectors.length).to eq(2)
      expect(filter.sectors).to include('public-sector')
      expect(filter.sectors).to include('private-sector')
    end
  end

  describe '.values' do
    it 'only contains whitelisted values' do
      create(:value, slug: 'unknown')
      params = { values: %w[nothing unknown] }
      filters = SearchFilter.new(params)

      expect(filters.values).to include('unknown')
      expect(filters.values).not_to include('nothing')
    end

    it 'returns an empty array when no value params' do
      params = {}
      filter = SearchFilter.new(params)

      expect(filter.values).to eq([])
    end

    it 'returns an array of value slugs' do
      create(:sector, slug: 'unknown')
      create(:sector, slug: 'over-amount')
      params = { sectors: %w[unknown over-amount] }
      filter = SearchFilter.new(params)

      expect(filter.sectors.length).to eq(2)
      expect(filter.sectors).to include('unknown')
      expect(filter.sectors).to include('over-amount')
    end
  end
end
