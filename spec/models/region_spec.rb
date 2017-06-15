require 'rails_helper'

RSpec.describe Region, type: :model do
  describe '#with name' do
    it 'returns regions' do
      regions = create_list(:region, 3, name: Faker::Lorem.name)
      expect(regions.to_s).to include(described_class.name)
    end
  end
end
