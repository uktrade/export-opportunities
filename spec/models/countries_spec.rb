require 'rails_helper'

describe Country, type: :model do
  describe '#with_exporting_guide' do
    it 'returns only countries that have exporting guides' do
      with_guide = create_list(:country, 3, exporting_guide_path: "/file/#{Faker::Lorem.word}")
      without_guide = create_list(:country, 3)
      expect(described_class.with_exporting_guide).to match_array(with_guide)
      expect(described_class.with_exporting_guide).not_to include(without_guide)
    end
  end
end
