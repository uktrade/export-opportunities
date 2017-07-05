require 'rails_helper'

RSpec.describe ReportCSV, type: :model do
  skip('TODO: create factories, test row_for')
  describe '#' do
    it 'returns regions' do
      regions = create_list(:region, 3, name: Faker::Lorem.name)
      expect(regions.to_s).to include(described_class.name)
    end
  end
end
