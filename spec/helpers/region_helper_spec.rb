# coding: utf-8

require 'rails_helper'

describe RegionHelper do
  before(:all) do
    country_list = %w[mexico austria belgium spain france australia germany ireland luxembourg new-zealand papua-new-guinea netherlands fiji switzerland romania qatar china cyprus greece israel italy iran portugal]
    country_list.each do |country|
      create(:country, name: country.tr('-', ' '), slug: country)
    end
    @countries = Country.all.where(slug: country_list)
  end

  describe '#convert_areas_params_into_regions_and_countries' do
    it 'should return regions and countries when both are found' do
      params = { areas: %w[south-america australia-new-zealand spain mexico western-europe france] }
      params = region_and_country_param_conversion(params)

      expect(params[:countries]).to eq(%w[spain mexico france])
      expect(params[:regions]).to eq(%w[south-america australia-new-zealand western-europe])
    end

    it 'should return just regions when no countries are found' do
      params = { areas: %w[south-america australia-new-zealand western-europe] }
      params = region_and_country_param_conversion(params)

      expect(params[:countries]).to eq([])
      expect(params[:regions]).to eq(%w[south-america australia-new-zealand western-europe])
    end

    it 'should return just countries when no regions are found' do
      params = { areas: %w[spain mexico france] }
      params = region_and_country_param_conversion(params)

      expect(params[:countries]).to eq(%w[spain mexico france])
      expect(params[:regions]).to eq([])
    end

    it 'should return unchanged params when areas is empty' do
      params = { areas: [], countries: %w[spain mexico], regions: %w[south-america] }
      params = region_and_country_param_conversion(params)

      expect(params[:countries]).to eq(%w[spain mexico])
      expect(params[:regions]).to eq(%w[south-america])
    end

    it 'should return unchanged params when countries are present' do
      params = { areas: %w[south-america], countries: %w[spain mexico], regions: [] }
      params = region_and_country_param_conversion(params)

      expect(params[:countries]).to eq(%w[spain mexico])
      expect(params[:regions]).to eq([])
    end

    it 'should return unchanged params when countries are present' do
      params = { areas: %w[south-america], countries: [], regions: %w[south-america] }
      params = region_and_country_param_conversion(params)

      expect(params[:countries]).to eq([])
      expect(params[:regions]).to eq(%w[south-america])
    end
  end

  describe '#regions_and_countries_from' do
    it 'returns a collection of regions and countries when regions are found' do
      regions_and_countries = regions_and_countries_from(@countries)
      example_country = @countries.first
      example_region =  { slug: 'australia-new-zealand', countries: %w[australia fiji new-zealand papua-new-guinea], name: 'Australia/New Zealand' }

      region_slugs = []
      regions_and_countries[:regions].each do |region|
        region_slugs.push(region[:slug])
      end

      country_slugs = []
      regions_and_countries[:countries].each do |country|
        country_slugs.push(country[:slug])
      end

      # Has correct regions
      expect(regions_and_countries[:regions].length).to eq(4)
      expect(regions_and_countries[:regions]).to include(example_region)
      expect(region_slugs).to include('western-europe')
      expect(region_slugs).to include('mediterranean-europe')
      expect(region_slugs).to include('australia-new-zealand')
      expect(region_slugs).to include('china')

      # Has correct countries
      expect(regions_and_countries[:countries].length).to eq(4)
      expect(regions_and_countries[:countries]).to include(example_country)
      expect(country_slugs).to eq(%w[mexico romania qatar iran])
    end

    it 'returns a collection of countries and (empty) regions when no regions are matched' do
      regions_and_countries = regions_and_countries_from(@countries.slice(0, 4))
      country_slugs = []
      regions_and_countries[:countries].each do |country|
        country_slugs.push(country[:slug])
      end

      expect(regions_and_countries[:regions].length).to eq(0)
      expect(regions_and_countries[:countries].length).to eq(4)
      expect(country_slugs).to eq(%w[mexico austria belgium spain])
    end
  end

  describe '#regions_and_countries_from_to_h' do
    it 'returns nothing if input is empty' do
      regions_and_countries = region_and_country_names_to_h([])
      expect(regions_and_countries).to eq ''
    end

    it 'returns something if input is valid' do
      regions_and_countries = region_and_country_names_to_h(@countries)

      expected = 'Western Europe, Mediterranean Europe, Australia/New Zealand, China, Mexico, Romania, Qatar and Iran'
      expected.gsub(" and", ",").split(", ").each do |item|
        expect(regions_and_countries).to include(item),
          "regions_and_countries did not include #{item}"
      end
    end
  end

  describe '#region_by_country' do
    it 'returns a region when one is found' do
      region = region_by_country(@countries.first)

      expect(region.present?).to be_truthy
      expect(region[:slug]).to eq('south-america')
      expect(region[:name]).to eq('South America')
      expect(region[:countries].length).to eq(12)
    end

    it 'returns an empty hash when no region is found' do
      region = region_by_country(create(:country, name: 'The Land of Giants'))

      expect(region).to be_nil
    end
  end

  describe '#region_by_name' do
    it 'returns a region when one is found' do
      region = region_by_name('Western Europe')

      expect(region.present?).to be_truthy
      expect(region[:slug]).to eq('western-europe')
      expect(region[:name]).to eq('Western Europe')
      expect(region[:countries].length).to eq(8)
    end

    it 'returns an empty hash when no region is found' do
      region = region_by_name('Oceania')

      expect(region).to be_nil
    end
  end

  describe '#region_by_slug' do
    it 'returns a region when one is found' do
      region = region_by_slug('western-europe')

      expect(region.present?).to be_truthy
      expect(region[:slug]).to eq('western-europe')
      expect(region[:name]).to eq('Western Europe')
      expect(region[:countries].length).to eq(8)
    end

    it 'returns an empty hash when no region is found' do
      region = region_by_slug('oceania')

      expect(region).to be_nil
    end
  end

  describe '#region_by_countries' do
    it 'returns a region when one is found' do
      region = region_by_countries(Country.all.where(slug: %w[australia new-zealand papua-new-guinea fiji]))

      expect(region.present?).to be_truthy
      expect(region[:slug]).to eq('australia-new-zealand')
      expect(region[:name]).to eq('Australia/New Zealand')
      expect(region[:countries].length).to eq(4)
    end

    it 'returns an empty hash when no region is found' do
      region = region_by_countries(Country.all.where(slug: %w[australia new-zealand papua-new-guinea]))

      expect(region).to be_nil
    end
  end

  describe '#regions_list' do
    it 'returns a list of region hashes' do
      checked = []
      regions_list.each do |region|
        checked.push(region.class == Hash)
      end

      expect(regions_list.length).to eq(17)
      expect(checked.include?(false)).to be_falsey
    end
  end
end
