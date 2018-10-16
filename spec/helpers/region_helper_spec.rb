# coding: utf-8

require 'rails_helper'

describe RegionHelper do
  before(:all) do
    @countries = Country.all.where(slug: ['mexico', 'austria', 'belgium', 'spain', 'france', 'austrailia', 'germany', 'ireland', 'luxembourg', 'new-zealand', 'papua-new-guinea', 'netherlands', 'fiji', 'switzerland', 'romania', 'qatar', 'china', 'cybrus', 'greece', 'israel', 'italy', 'iran', 'portugal'])
  end

  describe '#convert_areas_params_into_regions_and_countries' do
    it 'should return regions and countries when both are found' do
      params = { areas: %w[south_america australia_new_zealand spain mexico western_europe france] }
      params = convert_areas_params_into_regions_and_countries(params)

      expect(params[:countries]).to eq(%w[spain mexico france])
      expect(params[:regions]).to eq(%w[south_america australia_new_zealand western_europe])
    end

    it 'should return just regions when no countries are found' do
      params = { areas: %w[south_america australia_new_zealand western_europe] }
      params = convert_areas_params_into_regions_and_countries(params)

      expect(params[:countries]).to eq([])
      expect(params[:regions]).to eq(%w[south_america australia_new_zealand western_europe])
    end

    it 'should return just countries when no regions are found' do
      params = { areas: %w[spain mexico france] }
      params = convert_areas_params_into_regions_and_countries(params)

      expect(params[:countries]).to eq(%w[spain mexico france])
      expect(params[:regions]).to eq([])
    end

    it 'should return unchanged params when areas is empty' do
      params = { areas: [], countries: %w[spain mexico], regions: %w[south_america] }
      params = convert_areas_params_into_regions_and_countries(params)

      expect(params[:countries]).to eq(%w[spain mexico])
      expect(params[:regions]).to eq(%w[south_america])
    end

    it 'should return unchanged params when countries are present' do
      params = { areas: %w[south_america], countries: %w[spain mexico], regions: [] }
      params = convert_areas_params_into_regions_and_countries(params)

      expect(params[:countries]).to eq(%w[spain mexico])
      expect(params[:regions]).to eq([])
    end

    it 'should return unchanged params when countries are present' do
      params = { areas: %w[south_america], countries: [], regions: %w[south_america] }
      params = convert_areas_params_into_regions_and_countries(params)

      expect(params[:countries]).to eq([])
      expect(params[:regions]).to eq(%w[south_america])
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
