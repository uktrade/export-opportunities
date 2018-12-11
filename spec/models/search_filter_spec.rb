# coding: utf-8
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

    it 'returns an array of sector names' do
      create(:sector, name: 'Airport sector', slug: 'airports')
      create(:sector, name: 'Station sector',  slug: 'stations')
      params = { sectors: %w[airports stations] }
      filter = SearchFilter.new(params)

      expect(filter.sectors(:name).length).to eq(2)
      expect(filter.sectors(:name)).to include('Airport sector')
      expect(filter.sectors(:name)).to include('Station sector')
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
      params = { region: %w[europe asia] }
      filter = SearchFilter.new(params)

      expect(filter.regions.length).to eq(2)
      expect(filter.regions).to include('europe')
      expect(filter.regions).to include('asia')
    end

    it 'returns an array of region names' do
      params = { regions: %w[europe asia] }
      filter = SearchFilter.new(params)

      expect(filter.regions(:name).length).to eq(2)
      expect(filter.regions(:name)).to include('Europe')
      expect(filter.regions(:name)).to include('Asia')
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
      create(:country, slug: 'france')
      create(:country, slug: 'spain')
      params = { countries: %w[france spain] }
      filter = SearchFilter.new(params)

      expect(filter.countries.length).to eq(2)
      expect(filter.countries).to include('france')
      expect(filter.countries).to include('spain')
    end

    it 'returns an array of country names' do
      create(:country, name: 'France', slug: 'france')
      create(:country, name: 'Spain',  slug: 'spain')
      params = { countries: %w[france spain] }
      filter = SearchFilter.new(params)

      expect(filter.countries(:name).length).to eq(2)
      expect(filter.countries(:name)).to include('France')
      expect(filter.countries(:name)).to include('Spain')
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
      create(:type, slug: 'public-sector')
      create(:type, slug: 'private-sector')
      params = { types: %w[public-sector private-sector] }
      filter = SearchFilter.new(params)

      expect(filter.types.length).to eq(2)
      expect(filter.types).to include('public-sector')
      expect(filter.types).to include('private-sector')
    end

    it 'returns an array of type names' do
      create(:type, name: 'Public Sector', slug: 'public-sector')
      create(:type, name: 'Private Sector',  slug: 'private-sector')
      params = { types: %w[public-sector private-sector] }
      filter = SearchFilter.new(params)

      expect(filter.types(:name).length).to eq(2)
      expect(filter.types(:name)).to include('Public Sector')
      expect(filter.types(:name)).to include('Private Sector')
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
      create(:value, slug: 'unknown')
      create(:value, slug: 'over-amount')
      params = { values: %w[unknown over-amount] }
      filter = SearchFilter.new(params)

      expect(filter.values.length).to eq(2)
      expect(filter.values).to include('unknown')
      expect(filter.values).to include('over-amount')
    end

    it 'returns an array of value names' do
      create(:value, name: 'Unknown', slug: 'unknown')
      create(:value, name: 'over £100K',  slug: 'over-amount')
      params = { values: %w[unknown over-amount] }
      filter = SearchFilter.new(params)

      expect(filter.values(:name).length).to eq(2)
      expect(filter.values(:name)).to include('Unknown')
      expect(filter.values(:name)).to include('over £100K')
    end
  end
end
