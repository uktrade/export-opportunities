# coding: utf-8
require 'rails_helper'

RSpec.describe Poc::OpportunityPresenter do
  describe '#initialize' do
    it 'initializes a presenter' do
      opportunity = create(:opportunity, teaser: 'Opportunity teaser')
      presenter = Poc::OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      expect(presenter.teaser).to eq('Opportunity teaser')
    end
  end

  describe '#buyer_details_empty?' do
    it 'returns true when buyer details empty' do
      opportunity = create(:opportunity)
      # TODO: opportunity.rb currently stipulates CONTACTS_PER_OPPORTUNITY = 2
      # Believe that validation should change as per Jira[XOT-207]
      opportunity.contacts = []
      presenter = Poc::OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      expect(presenter.buyer_details_empty?).to eq true
    end

    it 'returns false when has buyer name' do
      opportunity = create(:opportunity, buyer_address: 'Buckingham Palace')
      presenter = Poc::OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      # TODO: Remove contacts reset after Jira[XOT-207] to test this properly.
      opportunity.contacts = []

      expect(presenter.buyer_details_empty?).to eq false
    end

    it 'returns false when has buyer address' do
      opportunity = create(:opportunity, buyer_name: 'Fred Spendalot')
      presenter = Poc::OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      # TODO: Remove contacts reset after Jira[XOT-207] to test this properly.
      opportunity.contacts = []

      expect(presenter.buyer_details_empty?).to eq false
    end

    it 'returns false when has a contact' do
      opportunity = create(:opportunity)
      presenter = Poc::OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      # Expect this to fail when Jira[XOT-207] complete.
      # Will need to create a fake contact(s) after that.

      expect(presenter.buyer_details_empty?).to eq false
    end
  end
end
