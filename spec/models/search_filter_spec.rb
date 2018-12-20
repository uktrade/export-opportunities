# coding: utf-8
require 'rails_helper'

RSpec.describe SearchFilter, type: :service do
  describe '.sectors' do
    it 'only contains whitelisted sector slugs' do
      create(:sector, slug: 'airports')
      params = { sectors: %w[mind-control airports] }
      filters = SearchFilter.new(params)
      sector_slugs = filters.sectors

      expect(sector_slugs).to include('airports')
      expect(sector_slugs).not_to include('mind-control')
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
      sector_slugs = filter.sectors

      expect(sector_slugs.length).to eq(2)
      expect(sector_slugs).to include('airports')
      expect(sector_slugs).to include('stations')
    end

    it 'returns an array of sector names' do
      create(:sector, name: 'Airport sector', slug: 'airports')
      create(:sector, name: 'Station sector',  slug: 'stations')
      params = { sectors: %w[airports stations] }
      filter = SearchFilter.new(params)
      sector_names = filter.sectors(:name)

      expect(sector_names.length).to eq(2)
      expect(sector_names).to include('Airport sector')
      expect(sector_names).to include('Station sector')
    end

    it 'returns an array of sector data' do
      create(:sector, name: 'Airport sector', slug: 'airports')
      create(:sector, name: 'Station sector',  slug: 'stations')
      params = { sectors: %w[airports stations] }
      filter = SearchFilter.new(params)
      sector_data = filter.sectors(:data)

      expect(sector_data.length).to eq(2)
      sector_data.each do |sector|
        expect(sector[:name]).to eq('Airport sector').or eq('Station sector')
        expect(sector[:slug]).to eq('airports').or eq('stations')
      end
    end
  end

  describe '.regions' do
    it 'only contains whitelisted regions' do
      params = { regions: %w[western-europe hackistan] }
      filter = SearchFilter.new(params)
      region_slugs = filter.regions

      expect(region_slugs).to include('western-europe')
      expect(region_slugs).not_to include('hackistan')
    end

    it 'returns an empty array when no region params' do
      params = {}
      filter = SearchFilter.new(params)

      expect(filter.regions).to eq([])
    end

    it 'returns an array of region slugs' do
      params = { regions: %w[western-europe south-asia] }
      filter = SearchFilter.new(params)
      region_slugs = filter.regions

      expect(region_slugs.length).to eq(2)
      expect(region_slugs).to include('western-europe')
      expect(region_slugs).to include('south-asia')
    end

    it 'returns an array of region names' do
      params = { regions: %w[western-europe south-asia] }
      filter = SearchFilter.new(params)
      region_names = filter.regions(:name)

      expect(region_names.length).to eq(2)
      expect(region_names).to include('Western Europe')
      expect(region_names).to include('South Asia')
    end

    it 'returns an array of region data' do
      params = { regions: %w[western-europe south-asia] }
      filter = SearchFilter.new(params)
      region_data = filter.regions(:data)

      expect(region_data.length).to eq(2)
      region_data.each do |region|
        expect(region[:name]).to eq('Western Europe').or eq('South Asia')
        expect(region[:slug]).to eq('western-europe').or eq('south-asia')
      end
    end
  end

  describe '.countries' do
    it 'only contains whitelisted countries' do
      create(:country, slug: 'australia')
      params = { countries: %w[australia hackistan] }
      filter = SearchFilter.new(params)
      country_slugs = filter.countries

      expect(country_slugs).to include('australia')
      expect(country_slugs).not_to include('hackistan')
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
      country_slugs = filter.countries

      expect(country_slugs.length).to eq(2)
      expect(country_slugs).to include('france')
      expect(country_slugs).to include('spain')
    end

    it 'returns an array of country names' do
      create(:country, name: 'France', slug: 'france')
      create(:country, name: 'Spain',  slug: 'spain')
      params = { countries: %w[france spain] }
      filter = SearchFilter.new(params)
      country_names = filter.countries(:name)

      expect(country_names.length).to eq(2)
      expect(country_names).to include('France')
      expect(country_names).to include('Spain')
    end

    it 'returns an array of country data' do
      create(:country, name: 'France', slug: 'france')
      create(:country, name: 'Spain',  slug: 'spain')
      params = { countries: %w[france spain] }
      filter = SearchFilter.new(params)
      country_data = filter.countries(:data)

      expect(country_data.length).to eq(2)
      country_data.each do |country|
        expect(country[:name]).to eq('France').or eq('Spain')
        expect(country[:slug]).to eq('france').or eq('spain')
      end
    end

    it 'returns an array of country slugs both from countries and region params' do
      create(:country, slug: 'france')
      create(:country, slug: 'spain')
      create(:country, slug: 'japan')
      create(:country, slug: 'south-korea')
      create(:country, slug: 'taiwan')
      params = { countries: %w[france spain], regions: %w[north-east-asia] }
      filter = SearchFilter.new(params)
      country_slugs = filter.countries

      expect(country_slugs.length).to eq(5)
      expect(country_slugs).to include('france')
      expect(country_slugs).to include('spain')
      expect(country_slugs).to include('japan')
      expect(country_slugs).to include('south-korea')
      expect(country_slugs).to include('taiwan')
    end
  end

  describe '.types' do
    it 'only contains whitelisted types' do
      create(:type, slug: 'public')
      params = { types: %w[evil-empire public] }
      filter = SearchFilter.new(params)
      type_slugs = filter.types

      expect(type_slugs).to include('public')
      expect(type_slugs).not_to include('evil-empire')
    end

    it 'returns an empty array when no type params' do
      params = {}
      filter = SearchFilter.new(params)

      expect(filter.types).to eq([])
    end

    it 'returns an array of type slugs' do
      create(:type, slug: 'public')
      create(:type, slug: 'private')
      params = { types: %w[public private] }
      filter = SearchFilter.new(params)
      type_slugs = filter.types

      expect(type_slugs.length).to eq(2)
      expect(type_slugs).to include('public')
      expect(type_slugs).to include('private')
    end

    it 'returns an array of type names' do
      create(:type, name: 'Public Sector', slug: 'public')
      create(:type, name: 'Private Sector',  slug: 'private')
      params = { types: %w[public private] }
      filter = SearchFilter.new(params)
      type_names = filter.types(:name)

      expect(type_names.length).to eq(2)
      expect(type_names).to include('Public Sector')
      expect(type_names).to include('Private Sector')
    end

    it 'returns an array of type data' do
      create(:type, name: 'Public Sector', slug: 'public')
      create(:type, name: 'Private Sector',  slug: 'private')
      params = { types: %w[public private] }
      filter = SearchFilter.new(params)
      type_data = filter.types(:data)

      expect(type_data.length).to eq(2)
      type_data.each do |type|
        expect(type[:name]).to eq('Public Sector').or eq('Private Sector')
        expect(type[:slug]).to eq('public').or eq('private')
      end
    end
  end

  describe '.values' do
    it 'only contains whitelisted values' do
      create(:value, slug: 'unknown')
      params = { values: %w[nothing unknown] }
      filter = SearchFilter.new(params)
      value_slugs = filter.values

      expect(value_slugs).to include('unknown')
      expect(value_slugs).not_to include('nothing')
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
      value_slugs = filter.values

      expect(value_slugs.length).to eq(2)
      expect(value_slugs).to include('unknown')
      expect(value_slugs).to include('over-amount')
    end

    it 'returns an array of value names' do
      create(:value, name: 'Unknown', slug: 'unknown')
      create(:value, name: 'over £100K',  slug: 'over-amount')
      params = { values: %w[unknown over-amount] }
      filter = SearchFilter.new(params)
      value_names = filter.values(:name)

      expect(value_names.length).to eq(2)
      expect(value_names).to include('Unknown')
      expect(value_names).to include('over £100K')
    end

    it 'returns an array of value data' do
      create(:value, name: 'Unknown', slug: 'unknown')
      create(:value, name: 'over £100K',  slug: 'over-amount')
      params = { values: %w[unknown over-amount] }
      filter = SearchFilter.new(params)
      value_data = filter.values(:data)

      expect(value_data.length).to eq(2)
      value_data.each do |value|
        expect(value[:name]).to eq('Unknown').or eq('over £100K')
        expect(value[:slug]).to eq('unknown').or eq('over-amount')
      end
    end
  end

  describe '.reduced_countries' do
    it 'only contains whitelisted countries not including those in regions' do
      create(:country, slug: 'australia')
      create(:country, slug: 'japan')
      params = { countries: %w[australia hackistan], regions: %w[north-east-asia] }
      filter = SearchFilter.new(params)
      reduced_country_slugs = filter.reduced_countries

      expect(reduced_country_slugs).to include('australia')
      expect(reduced_country_slugs).not_to include('hackistan')
    end

    it 'returns an empty array when no country params' do
      params = {}
      filter = SearchFilter.new(params)

      expect(filter.reduced_countries).to eq([])
    end

    it 'returns an array of country slugs' do
      create(:country, slug: 'france')
      create(:country, slug: 'spain')
      create(:country, slug: 'japan')
      params = { countries: %w[france spain], regions: %w[north-east-asia] }
      filter = SearchFilter.new(params)
      reduced_country_slugs = filter.reduced_countries

      expect(reduced_country_slugs.length).to eq(2)
      expect(reduced_country_slugs).to include('france')
      expect(reduced_country_slugs).to include('spain')
    end

    it 'returns an array of country names' do
      create(:country, name: 'France', slug: 'france')
      create(:country, name: 'Spain',  slug: 'spain')
      create(:country, slug: 'japan')
      params = { countries: %w[france spain], regions: %w[north-east-asia] }
      filter = SearchFilter.new(params)

      expect(filter.reduced_countries(:name).length).to eq(2)
      expect(filter.reduced_countries(:name)).to include('France')
      expect(filter.reduced_countries(:name)).to include('Spain')
    end

    it 'returns an array of country data' do
      create(:country, name: 'France', slug: 'france')
      create(:country, name: 'Spain',  slug: 'spain')
      create(:country, slug: 'japan')
      params = { countries: %w[france spain], regions: %w[north-east-asia] }
      filter = SearchFilter.new(params)
      country_data = filter.reduced_countries(:data)

      expect(country_data.length).to eq(2)
      country_data.each do |country|
        expect(country[:name]).to eq('France').or eq('Spain')
        expect(country[:slug]).to eq('france').or eq('spain')
      end
    end

    it 'returns an array of country slugs both from countries and region params' do
      create(:country, slug: 'france')
      create(:country, slug: 'spain')
      create(:country, slug: 'japan')
      create(:country, slug: 'south-korea')
      create(:country, slug: 'taiwan')
      params = { countries: %w[france spain], regions: %w[north-east-asia] }
      filter = SearchFilter.new(params)
      reduced_country_slugs = filter.reduced_countries

      expect(reduced_country_slugs.length).to eq(2)
      expect(reduced_country_slugs).to include('france')
      expect(reduced_country_slugs).to include('spain')
      expect(reduced_country_slugs).to_not include('japan')
      expect(reduced_country_slugs).to_not include('south-korea')
      expect(reduced_country_slugs).to_not include('taiwan')
    end
  end
end
