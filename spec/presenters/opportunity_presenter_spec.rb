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

  describe '#enquiries_total' do
    it 'returns correct number of enquiries' do
      enquiry_1 = create(:enquiry)
      enquiry_2 = create(:enquiry)
      opportunity = create(:opportunity, enquiries: [enquiry_1, enquiry_2])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      expect(presenter.enquiries_total).to eq(2)
    end

    it 'returns zero when opportunity has no enquiries' do
      opportunity = create(:opportunity)
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      expect(presenter.enquiries_total).to eq(0)
    end
  end

  describe '#type' do
    it 'returns the correct opportunity type when only has one' do
      type = create(:type, name: 'Public Sector')
      opportunity = create(:opportunity, types: [type])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      expect(presenter.type).to eq('Public Sector')
    end

    it 'returns the correct opportunity type when has more than one' do
      type_1 = create(:type, name: 'Public Sector')
      type_2 = create(:type, name: 'Public Sector')
      opportunity = create(:opportunity, types: [type_1, type_2])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      expect(presenter.type).to eq('Public Sector and Public Sector')
    end
  end

  describe '#sectors_as_string' do
    it 'returns empty string when sectors uninitialised' do
      opportunity = create(:opportunity)
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      expect(presenter.sectors_as_string).to eq('')
    end

    it 'returns empty string when has no sectors' do
      opportunity = create(:opportunity, sectors: [])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      expect(presenter.sectors_as_string).to eq('')
    end

    it 'returns single sector as a string' do
      sector_1 = create(:sector, name: 'Aerospace')
      opportunity = create(:opportunity, sectors: [sector_1])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      expect(presenter.sectors_as_string).to eq('Aerospace')
    end

    it 'returns multiple sectors as a string' do
      sector_1 = create(:sector, name: 'Aerospace')
      sector_2 = create(:sector, name: 'Agriculture')
      opportunity = create(:opportunity, sectors: [sector_1, sector_2])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      expect(presenter.sectors_as_string).to eq('Aerospace and Agriculture')
    end
  end

  describe '#value' do
    it 'returns opportunity value' do
      value = create(:value, name: '100k')
      opportunity = create(:opportunity, values: [value])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      expect(presenter.value).to eq('100k')
    end

    it 'returns first value from multiple' do
      value_1 = create(:value, name: '100k')
      value_2 = create(:value, name: '150k')
      opportunity = create(:opportunity, values: [value_1, value_2])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      expect(presenter.value).to eq('100k')
      expect(presenter.value).to_not eq('150k')
    end

    it 'returns "Value unknown" when has no value' do
      opportunity = create(:opportunity)
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      expect(presenter.value).to eq('Value unknown')
    end
  end

  describe '#contact' do
    it 'return contact email when has one' do
      contact = create(:contact, email: 'foo@bar.com')
      opportunity = create(:opportunity, contacts: [contact])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      expect(presenter.contact).to eq('foo@bar.com')
    end

    it 'return contact name when does not have email' do
      contact = create(:contact)
      opportunity = create(:opportunity, contacts: [contact])

      # Only likely on third-party Opps??
      opportunity.contacts.first.name = 'fred' 
      opportunity.contacts.first.email = ''
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      expect(presenter.contact).to eq('fred')
    end

    it 'return "Contact unknown" when does not have email or contact name' do
      opportunity = create(:opportunity)
      opportunity.contacts = [] # because create adds a default even if we pass an empty Array
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      expect(presenter.contact).to eq('Contact unknown')
    end
  end

  describe '#guides_available' do
    skip 'TODO: On hold due to related work required for JIRA#XOT-271'
  end

  describe '#country_guides' do
    skip 'TODO: ...'
  end

  describe '#industry_links' do
    it 'Returns a relevant link to when has an industry' do
      opportunity = create(:opportunity, sectors: [create(:sector, name: 'this is a sector name')])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)
      links = presenter.industry_links

      expect(links).to include('href=') # should mean it is an html link
      expect(links).to include('this is a sector name')
    end

    it 'Returns multipls links when has more than one industry' do
      opportunity = create(:opportunity, sectors: [create(:sector, name: 'sector_1'), create(:sector, name: 'sector_2')])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)
      links = presenter.industry_links

      expect(links).to include('href=') # should mean it is an html link
      expect(links).to include('sector_1')
      expect(links).to include('sector_2')
    end

    it 'Returns an empty string when has no industries' do
      opportunity = create(:opportunity)
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      expect(presenter.industry_links).to eql('')
    end
  end

  describe '#link_to_aid_funded' do
    it 'Returns HTML link if opportunity.aid_funded is true' do
      opportunity = create(:opportunity, types: [create(:type, slug: 'aid-funded-business')])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)
      link = presenter.link_to_aid_funded('foo')

      expect(link).to include('href') # should mean it is a HTML link markup
      expect(link).to include('https://www.gov.uk/guidance/aid-funded-business') # should mean it has correct url
      expect(link).to include('foo') # should mean it injects the passed link text
    end

    it 'Returns empty string if opportunity.aid_funded is false' do
      opportunity = create(:opportunity, types: [create(:type)])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)
      link = presenter.link_to_aid_funded('foo')

      expect(link).to eql('')
    end
  end

  describe '#source' do
    it 'Returns true if the source matches passed string' do
      opportunity = create(:opportunity, source: 1)
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      expect(presenter.source('volume_opps')).to be_truthy
    end

    it 'Returns false if the source matches passed string' do
      opportunity = create(:opportunity, source: 1)
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity)

      expect(presenter.source('foo')).to be_falsey
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
