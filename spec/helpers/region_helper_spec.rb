# coding: utf-8

require 'rails_helper'

describe RegionHelper do
  describe '#convert_areas_params_into_regions_and_countries' do
    it 'does something...' do
      params = { areas: %w[south_america australia_new_zealand spain mexico western_europe france] }
      params = convert_areas_params_into_regions_and_countries(params)

      expect(params[:countries]).to eq(%w[spain mexico france])
      expect(params[:regions]).to eq(%w[south_america australia_new_zealand western_europe])
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
