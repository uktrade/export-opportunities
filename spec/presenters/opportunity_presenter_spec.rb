# coding: utf-8
require 'rails_helper'

RSpec.describe OpportunityPresenter do
  describe '#initialize' do
    it 'initializes a presenter' do
      opportunity = create(:opportunity, teaser: 'Opportunity teaser')
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      expect(presenter.teaser).to eq('Opportunity teaser')
    end
  end

  describe '#title_with_country' do
    it 'does not change title if source is post' do
      opportunity = create(:opportunity, title: 'foo', source: 0)
      opportunity.countries = create_list(:country, 2)
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      expect(opportunity.source).to eq('post')
      expect(presenter.title_with_country).to eq('foo')
    end

    it 'adds "Multi Country" if opportunity has more than one country' do
      opportunity = create(:opportunity, title: 'foo', source: 1)
      opportunity.countries = create_list(:country, 2)
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      expect(opportunity.source).to_not eq('post')
      expect(presenter.title_with_country).to eq('Multi Country - foo')
    end

    it 'adds country to opportunity title' do
      country = create(:country, name: 'Iran')
      opportunity = create(:opportunity, title: 'foo', source: 1, countries: [country])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)
      expect(opportunity.source).to_not eq('post')
      expect(presenter.title_with_country).to eq('Iran - foo')
    end
  end

  describe '#first_country' do
    it 'returns first opportunity country name only' do
      country_1 = create(:country, name: 'Iran')
      country_2 = create(:country, name: 'France')
      opportunity = create(:opportunity, countries: [country_1, country_2])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      expect(opportunity.countries.size).to eq(2)
      expect(presenter.first_country).to eq('Iran')
    end

    it 'returns blank string if no country' do
      opportunity = create(:opportunity, countries: [])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      expect(opportunity.countries.size).to eq(0)
      expect(presenter.first_country).to eq('')
    end
  end

  describe '#description' do
    it 'returns opportunity.description' do
      opportunity = create(:opportunity, description: 'Opportunity description')
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      expect(presenter.description).to eq('<p>Opportunity description</p>')
    end
  end

  describe '#expires' do
    it 'returns formatted date string for response due time' do
      opportunity = create(:opportunity, response_due_on: '2019-02-01')
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      expect(presenter.expires).to eq('01 February 2019')
    end
  end

  describe '#buyer_details_empty?' do
    it 'returns true when buyer details empty' do
      opportunity = create(:opportunity)
      # TODO: opportunity.rb currently stipulates CONTACTS_PER_OPPORTUNITY = 2
      # Believe that validation should change as per Jira[XOT-207]
      opportunity.contacts = []
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      expect(presenter.buyer_details_empty?).to eq true
    end

    it 'returns false when has buyer name' do
      opportunity = create(:opportunity, buyer_address: 'Buckingham Palace')
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      # TODO: Remove contacts reset after Jira[XOT-207] to test this properly.
      opportunity.contacts = []

      expect(presenter.buyer_details_empty?).to eq false
    end

    it 'returns false when has buyer address' do
      opportunity = create(:opportunity, buyer_name: 'Fred Spendalot')
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      # TODO: Remove contacts reset after Jira[XOT-207] to test this properly.
      opportunity.contacts = []

      expect(presenter.buyer_details_empty?).to eq false
    end

    it 'returns false when has a contact' do
      opportunity = create(:opportunity)
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      # Expect this to fail when Jira[XOT-207] complete.
      # Will need to create a fake contact(s) after that.

      expect(presenter.buyer_details_empty?).to eq false
    end
  end
end
