require 'rails_helper'

RSpec.describe CreateOpportunitySlug do
  describe '#call' do
    it 'creates a slug from the opportunity title' do
      opportunity = double(title: 'Export tea to china (really)', id: nil)
      expect(subject.call(opportunity)).to eq 'export-tea-to-china-really'
    end

    it 'appends a random number to avoid duplicates' do
      create(:opportunity, title: 'Export basil to india', slug: 'export-basil-to-india')
      duplicate = double(title: 'Export Basil to India', id: nil)
      expect(subject.call(duplicate)).to match(/export\-basil\-to\-india\-\d+/)
    end

    it 'allows the same slug for the given opportunity' do
      opportunity = create(:opportunity, title: 'Export basil to india', slug: 'export-basil-to-india')
      expect(subject.call(opportunity)).to eq(opportunity.slug)
    end

    it 'returns the slug without a suffix if it cannot find a unique slug' do
      opportunity = create(:opportunity, title: 'Export basil to india', slug: 'export-basil-to-india')
      create(:opportunity, title: 'Export basil to india', slug: 'export-basil-to-india-5')
      allow(subject).to receive(:rand).and_return(5)
      duplicate = double(title: 'Export Basil to India', id: nil)
      expect(subject.call(duplicate)).to eq(opportunity.slug)
    end

    it 'retuns a nil if not title is provided' do
      duplicate = double(title: nil, id: nil)
      expect(subject.call(duplicate)).to be_nil
    end
  end
end
