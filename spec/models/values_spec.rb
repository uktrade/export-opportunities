require 'rails_helper'

RSpec.describe Value, type: :model do
  context '#valid' do
    it 'validates slug to be unique' do
      Value.create(name: '10k', slug: '10')
      value_with_duplicate_slug = Value.new(name: '100k', slug: '10')
      expect(value_with_duplicate_slug).not_to be_valid
    end
  end
end
