require 'rails_helper'

describe OpportunityFinder, type: :service do
  describe '#call' do
    it 'returns the opportunity when it exists' do
      opportunity = create(:opportunity, id: 1)
      allow(Opportunity).to receive(:find).with(1).and_return(opportunity)

      response = OpportunityFinder.new.call(1)

      expect(response.success?).to eq true
      expect(response.data).to eq opportunity
    end

    it 'returns a 404 error when it does not exist' do
      allow(Opportunity).to receive(:find)
        .with(1)
        .and_raise(ActiveRecord::RecordNotFound.new("Couldn't find Opportunity with 'id'=1"))

      response = OpportunityFinder.new.call(1)

      expect(response.success?).to eq false
      expect(response.error).to eq "Couldn't find Opportunity with 'id'=1"
      expect(response.code).to eq :not_found
    end
  end
end
