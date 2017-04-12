require 'rails_helper'

RSpec.describe OpportunityVersion do
  describe '#blame' do
    it 'returns the editor who made this change' do
      publisher = create(:publisher)
      PaperTrail.whodunnit = publisher.id

      opportunity = create(:opportunity, status: :pending)
      opportunity.status = :publish
      opportunity.save

      expect(opportunity.versions.last.blame).to eq publisher
    end

    context 'when no editor is available' do
      it 'returns a dummy editor' do
        PaperTrail.whodunnit = nil

        opportunity = create(:opportunity, status: :pending)
        opportunity.status = :publish
        opportunity.save

        expect(opportunity.versions.last.blame.name).to eq 'An administrator'
      end
    end
  end
end
