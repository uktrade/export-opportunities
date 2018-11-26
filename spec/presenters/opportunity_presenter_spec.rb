# coding: utf-8

require 'rails_helper'

RSpec.describe OpportunityPresenter do
  let(:content) { get_content('opportunities/show') }

  describe '#initialize' do
    it 'initializes a presenter' do
      opportunity = create(:opportunity, teaser: 'Opportunity teaser')
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(presenter.teaser).to eq('Opportunity teaser')
    end
  end

  describe '#title_with_country' do
    it 'does not change title if source is post and created before special date' do
      opportunity = create(:opportunity, title: 'foo', source: 0, created_at: Date.new(2018, 10, 7))
      opportunity.countries = create_list(:country, 2)
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(opportunity.source).to eq('post')
      expect(opportunity.created_at).to eq(Date.new(2018, 10, 7))
      expect(presenter.title_with_country).to eq('foo')
    end

    it 'does not change title if has no country assigned' do
      opportunity = create(:opportunity, title: 'foo', countries: [])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(presenter.title_with_country).to eq('foo')
    end

    it 'does not change title if only has no restricted country assigned' do
      country = create(:country, name: 'DIT HQ', id: 198)
      opportunity = create(:opportunity, title: 'foo', countries: [country])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(presenter.title_with_country).to eq('foo')
    end

    it 'adds "Multi Country" if opportunity has more than one country' do
      opportunity = create(:opportunity, title: 'foo', source: 1)
      opportunity.countries = create_list(:country, 2)
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(opportunity.source).to_not eq('post')
      expect(presenter.title_with_country).to eq('Multi Country - foo')
    end

    it 'adds country to opportunity title' do
      country = create(:country, name: 'Iran')
      opportunity = create(:opportunity, title: 'foo', source: 1, countries: [country], created_at: Date.new(2018, 10, 7))
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(opportunity.source).to_not eq('post')
      expect(opportunity.created_at).to eq(Date.new(2018, 10, 7))
      expect(presenter.title_with_country).to eq('Iran - foo')
    end
  end

  describe '#first_country' do
    it 'returns first opportunity country name only' do
      country1 = create(:country, name: 'Iran')
      country2 = create(:country, name: 'France')
      opportunity = create(:opportunity, countries: [country1, country2])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(opportunity.countries.size).to eq(2)
      expect(presenter.first_country).to eq('Iran')
    end

    it 'returns blank string if no country' do
      opportunity = create(:opportunity, countries: [])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(opportunity.countries.size).to eq(0)
      expect(presenter.first_country).to eq('')
    end
  end

  describe '#description' do
    it 'returns opportunity.description' do
      opportunity = create(:opportunity, description: 'Opportunity description')
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(presenter.description).to eq('<p>Opportunity description</p>')
    end
  end

  describe '#expires' do
    it 'returns formatted date string for response due time' do
      opportunity = create(:opportunity, response_due_on: '2019-02-01')
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(presenter.expires).to eq('01 February 2019')
    end
  end

  describe '#enquiries_total' do
    it 'returns correct number of enquiries' do
      enquiry1 = create(:enquiry)
      enquiry2 = create(:enquiry)
      opportunity = create(:opportunity, enquiries: [enquiry1, enquiry2])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(presenter.enquiries_total).to eq(2)
    end

    it 'returns zero when opportunity has no enquiries' do
      opportunity = create(:opportunity)
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(presenter.enquiries_total).to eq(0)
    end
  end

  describe '#type' do
    it 'returns the correct opportunity type when only has one' do
      type = create(:type, name: 'Public Sector')
      opportunity = create(:opportunity, types: [type])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(presenter.type).to eq('Public Sector')
    end

    it 'returns the correct opportunity type when has more than one' do
      type1 = create(:type, name: 'Public Sector')
      type2 = create(:type, name: 'Public Sector')
      opportunity = create(:opportunity, types: [type1, type2])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(presenter.type).to eq('Public Sector and Public Sector')
    end
  end

  describe '#sectors_as_string' do
    it 'returns empty string when sectors uninitialised' do
      opportunity = create(:opportunity)
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(presenter.sectors_as_string).to eq('')
    end

    it 'returns empty string when has no sectors' do
      opportunity = create(:opportunity, sectors: [])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(presenter.sectors_as_string).to eq('')
    end

    it 'returns single sector as a string' do
      sector1 = create(:sector, name: 'Aerospace')
      opportunity = create(:opportunity, sectors: [sector1])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(presenter.sectors_as_string).to eq('Aerospace')
    end

    it 'returns multiple sectors as a string' do
      sector1 = create(:sector, name: 'Aerospace')
      sector2 = create(:sector, name: 'Agriculture')
      opportunity = create(:opportunity, sectors: [sector1, sector2])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(presenter.sectors_as_string).to eq('Aerospace and Agriculture')
    end
  end

  describe '#value' do
    it 'returns opportunity value' do
      value = create(:value, name: '100k')
      opportunity = create(:opportunity, values: [value])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(presenter.value).to eq('100k')
    end

    it 'returns first value from multiple' do
      value1 = create(:value, name: '100k')
      value2 = create(:value, name: '150k')
      opportunity = create(:opportunity, values: [value1, value2])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(presenter.value).to eq('100k')
      expect(presenter.value).to_not eq('150k')
    end

    it 'returns "Value unknown" when has no value' do
      opportunity = create(:opportunity)
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(presenter.value).to eq('Value unknown')
    end
  end

  describe '#contact' do
    it 'return contact email when has one' do
      contact = create(:contact, email: 'foo@bar.com')
      opportunity = create(:opportunity, contacts: [contact])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(presenter.contact).to eq('foo@bar.com')
    end

    it 'return nil when has no contact email' do
      contact = create(:contact, email: nil)
      opportunity = create(:opportunity, contacts: [contact])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(presenter.contact).to eq(nil)
    end
  end

  describe '#guides_available' do
    it 'return true when has country guides' do
      countries = create_list(:country, 3, exporting_guide_path: "/file/#{Faker::Lorem.word}")
      opportunity = create(:opportunity, countries: countries)
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(presenter.guides_available).to be_truthy
    end

    it 'return false when has no counry cguides' do
      countries = create_list(:country, 3, exporting_guide_path: nil)
      opportunity = create(:opportunity, countries: countries)
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(presenter.guides_available).to be_falsey
    end
  end

  describe '#country_guides' do
    it 'Returns an empty Array when there are no country guides' do
      opportunity = create(:opportunity, countries: create_list(:country, 3))
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(presenter.country_guides).to eql([])
    end

    it 'Returns a list of country guide links' do
      countries = create_list(:country, 3, exporting_guide_path: "/file/#{Faker::Lorem.word}")
      opportunity = create(:opportunity, countries: countries)
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])
      links = presenter.country_guides

      expect(links.length).to eql(3)
      expect(links[0]).to include('href=')
      expect(links[0]).to include('/file/')
    end

    it 'Returns a single "Country guides" link when has more than 5 country guides' do
      countries = create_list(:country, 6, exporting_guide_path: "/file/#{Faker::Lorem.word}")
      opportunity = create(:opportunity, countries: countries)
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])
      links = presenter.country_guides

      expect(links.length).to eql(1)
      expect(links[0]).to include('href=')
      expect(links[0]).to include('Country guides')
    end
  end

  describe '#industry_links' do
    it 'Returns a relevant link to when has an industry' do
      opportunity = create(:opportunity, sectors: [create(:sector, name: 'this is a sector name')])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])
      links = presenter.industry_links

      expect(links).to include('href=') # should mean it is an html link
      expect(links).to include('this is a sector name')
    end

    it 'Returns multipls links when has more than one industry' do
      opportunity = create(:opportunity, sectors: [create(:sector, name: 'sector_1'), create(:sector, name: 'sector_2')])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])
      links = presenter.industry_links

      expect(links).to include('href=') # should mean it is an html link
      expect(links).to include('sector_1')
      expect(links).to include('sector_2')
    end

    it 'Returns an empty string when has no industries' do
      opportunity = create(:opportunity)
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(presenter.industry_links).to eql('')
    end
  end

  describe '#link_to_aid_funded' do
    it 'Returns HTML link if opportunity.aid_funded is true' do
      opportunity = create(:opportunity, types: [create(:type, slug: 'aid-funded-business')])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])
      link = presenter.link_to_aid_funded('foo')

      expect(link).to include('href') # should mean it is a HTML link markup
      expect(link).to include('https://www.gov.uk/guidance/aid-funded-business') # should mean it has correct url
      expect(link).to include('foo') # should mean it injects the passed link text
    end

    it 'Returns empty string if opportunity.aid_funded is false' do
      opportunity = create(:opportunity, types: [create(:type)])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])
      link = presenter.link_to_aid_funded('foo')

      expect(link).to eql('')
    end
  end

  describe '#source' do
    it 'Returns true if the source matches passed string' do
      opportunity = create(:opportunity, source: 1)
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(presenter.source('volume_opps')).to be_truthy
    end

    it 'Returns false if the source matches passed string' do
      opportunity = create(:opportunity, source: 1)
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(presenter.source('foo')).to be_falsey
    end
  end

  describe '#supplier_preferences' do
    it 'returns an empty string when has no supplier ids' do
      opportunity = create(:opportunity)
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(opportunity.supplier_preference_ids.length).to eql(0)
      expect(presenter.supplier_preferences).to be_empty
    end

    it 'returns a single supplier type as string when has one supplier id' do
      create(:supplier_preference, id: 1, slug: 'foo', name: 'foo')
      opportunity = create(:opportunity, supplier_preference_ids: [1])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(opportunity.supplier_preference_ids.length).to eql(1)
      expect(presenter.supplier_preferences).to eql('foo')
    end

    it 'returns comma-separated supplier types as a string when has more than one supplier id' do
      create(:supplier_preference, id: 1, slug: 'foo', name: 'foo')
      create(:supplier_preference, id: 2, slug: 'bar', name: 'bar')
      opportunity = create(:opportunity, supplier_preference_ids: [1, 2])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(opportunity.supplier_preference_ids.length).to eql(2)
      expect(presenter.supplier_preferences).to eql('foo, bar')
    end
  end

  describe '#supplier_preference?' do
    it 'returns true when opportunity has supplier preference ids' do
      create(:supplier_preference, id: 1, slug: 'foo', name: 'foo')
      create(:supplier_preference, id: 2, slug: 'bar', name: 'bar')
      create(:supplier_preference, id: 3, slug: 'diddle', name: 'diddle')
      opportunity = create(:opportunity, supplier_preference_ids: [1, 2])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(opportunity.supplier_preference_ids).to_not be_nil
      expect(opportunity.supplier_preference_ids).to_not be_empty
      expect(presenter.supplier_preference?).to be_truthy
    end

    it 'returns false when opportunity does not have supplier preference ids' do
      opportunity = create(:opportunity)
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(opportunity.supplier_preference_ids).to_not be_nil
      expect(opportunity.supplier_preference_ids).to be_empty
      expect(presenter.supplier_preference?).to be_falsey
    end
  end

  describe '#buyer_details_empty?' do
    it 'returns true when buyer details empty' do
      opportunity = create(:opportunity)
      # TODO: opportunity.rb currently stipulates CONTACTS_PER_OPPORTUNITY = 2
      # Believe that validation should change as per Jira[XOT-207]
      opportunity.contacts = []
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(presenter.buyer_details_empty?).to eq true
    end

    it 'returns false when has buyer name' do
      opportunity = create(:opportunity, buyer_address: 'Buckingham Palace')
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      # TODO: Remove contacts reset after Jira[XOT-207] to test this properly.
      opportunity.contacts = []

      expect(presenter.buyer_details_empty?).to eq false
    end

    it 'returns false when has buyer address' do
      opportunity = create(:opportunity, buyer_name: 'Fred Spendalot')
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      # TODO: Remove contacts reset after Jira[XOT-207] to test this properly.
      opportunity.contacts = []

      expect(presenter.buyer_details_empty?).to eq false
    end

    it 'returns false when has a contact' do
      opportunity = create(:opportunity)
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      # Expect this to fail when Jira[XOT-207] complete.
      # Will need to create a fake contact(s) after that.

      expect(presenter.buyer_details_empty?).to eq false
    end
  end

  describe '#translated?' do
    it 'returns false when opportunity has been translated' do
      opportunity = create(:opportunity, original_language: 'en')
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(presenter.translated?).to be_falsey
    end

    it 'returns true when opportunity has been translated' do
      opportunity = create(:opportunity, original_language: 'pl')
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(presenter.translated?).to be_truthy
    end
  end

  describe '#published_date' do
    it 'returns correctly formatted published date as string' do
      opportunity = create(:opportunity, :published, first_published_at: Date.new(2015, 9, 15))
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(presenter.published_date).to eql('15 September 2015')
    end
  end

  describe '#formatted_date' do
    it 'returns correctly formatted published date as string' do
      opportunity = create(:opportunity, :published, created_at: Date.new(2015, 9, 15))
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(presenter.formatted_date('created_at')).to eql('15 September 2015')
    end

    it 'returns empty string when no corresponding date property found' do
      opportunity = create(:opportunity, :published, first_published_at: Date.new(2015, 9, 15))
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(presenter.formatted_date('foo')).to eql('')
    end
  end

  describe '#sign_off_content' do
    # @target_url.present?
    it 'returns sign off content for Post opp with third-party URL' do
      provider = create(:service_provider)
      opportunity = create(:opportunity, target_url: '/foo/bar/')
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, content)
      lines = presenter.sign_off_content(provider)

      expect(lines.length).to eq(1)
      expect(lines[0]).to eq('For more information and to make a bid you will need to go to the third party website.')
    end

    # source('volume_opps')
    it 'returns sign off content for Open Opp' do
      opportunity = create(:opportunity, source: 'volume_opps')
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, content)
      lines = presenter.sign_off_content

      expect(lines.length).to eq(1)
      expect(lines[0]).to eq('If your company meets the requirements of the tender, go to the website where the tender is hosted and submit your bid.')
    end

    # partner.present?
    it 'returns sign off content for opp with partner' do
      country = create(:country)
      provider = create(:service_provider, country_id: country.id, partner: 'partner name')
      opportunity = create(:opportunity)
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, content)
      lines = presenter.sign_off_content(provider)
      partner_name = provider.partner
      country_name = provider.country.name

      expect(lines.length).to eq(2)
      expect(lines[0]).to eq("Express your interest to the #{partner_name} in #{country_name}.")
      expect(lines[1]).to eq("The #{partner_name} is our chosen partner to deliver trade services in #{country_name}.")
    end

    # ['specific', 'standard', 'provider', 'names', 'here'].include?(provider_name)
    it 'returns standard DIT sign off content for specific providers' do
      provider = create(:service_provider, name: 'DIT HQ')
      opportunity = create(:opportunity)
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, content)
      lines = presenter.sign_off_content(provider)

      expect(lines.length).to eq(1)
      expect(lines[0]).to eq('Express your interest to the Department for International Trade.')
    end

    # name.match(/Czech Republic \w+|Dominican Republic \w+|Ivory Coast \w+|Netherlands \w+|Philippines \w+|United Arab Emirates \w+|United States \w+/)
    it 'returns standard sign off content with \'the\' variant required for country name' do
      country = create(:country, name: 'Czech Republic')
      provider = create(:service_provider, name: 'Czech Republic Prague', country_id: country.id)
      opportunity = create(:opportunity)
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, content)
      lines = presenter.sign_off_content(provider)
      country_name = provider.country.name

      expect(lines.length).to eq(1)
      expect(lines[0]).to eq("Express your interest to the Department for International Trade team in the #{country_name}.")

      # And do another one to be sure...
      country = create(:country, name: 'USA')
      provider = create(:service_provider, name: 'United States Chicago', country_id: country.id)
      opportunity = create(:opportunity)
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, content)
      lines = presenter.sign_off_content(provider)
      country_name = provider.country.name

      expect(lines.length).to eq(1)
      expect(lines[0]).to eq("Express your interest to the Department for International Trade team in the #{country_name}.")
    end

    # name.match(/.*Africa.* \w+|Cameroon \w+|Egypt \w+|Kenya OBNI|Nabia \w+|Rwanda \w+|Senegal \w+|Seychelles \w+|Tanzania \w+|Tunisia \w+|Zambia \w+/)
    it 'returns standard sign off content with region name instead of country' do
      region = create(:region, name: 'Africa')
      country = create(:country, name: 'Cameroon', region_id: region.id)
      provider = create(:service_provider, name: 'Cameroon Yaounde', country_id: country.id)
      opportunity = create(:opportunity)
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, content)
      lines = presenter.sign_off_content(provider)
      country_name = provider.country.name

      expect(lines.length).to eq(1)
      expect(lines[0]).to eq("Express your interest to the Department for International Trade team in #{region.name}.")

      # And do another one to be sure...
      region = create(:region, name: 'Africa')
      country = create(:country, name: 'South Africa', region_id: region.id)
      provider = create(:service_provider, name: 'South Africa Johannesburg', country_id: country.id)
      opportunity = create(:opportunity)
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, content)
      lines = presenter.sign_off_content(provider)
      country_name = provider.country.name

      expect(lines.length).to eq(1)
      expect(lines[0]).to eq("Express your interest to the Department for International Trade team in #{region.name}.")
    end

    # else
    it 'returns standard sign off when no other condition matched' do
      country = create(:country, name: 'France')
      provider = create(:service_provider, country_id: country.id)
      opportunity = create(:opportunity)
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, content)
      lines = presenter.sign_off_content(provider)
      country_name = provider.country.name

      expect(lines.length).to eq(1)
      expect(lines[0]).to eq("Express your interest to the Department for International Trade team in #{country_name}.")
    end

    it 'returns a sign off when reading from opportunity.service_provider' do
      country = create(:country, name: 'France')
      provider = create(:service_provider, country_id: country.id)
      opportunity = create(:opportunity, service_provider_id: provider.id)
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, content)
      lines = presenter.sign_off_content
      country_name = provider.country.name

      expect(lines.length).to eq(1)
      expect(lines[0]).to eq("Express your interest to the Department for International Trade team in #{country_name}.")
    end
  end

  describe '::contact_email' do
    it 'returns the email of first contact' do
      contact1 = create(:contact, email: 'foo1@bar.com')
      contact2 = create(:contact, email: 'foo2@bar.com')
      opportunity = create(:opportunity, contacts: [contact1, contact2])
      presenter = OpportunityPresenter.new(ActionController::Base.helpers, opportunity, [])

      expect(presenter.send(:contact_email)).to eq('foo1@bar.com')
    end
  end

  # Helpers

  def has_html?(str)
    /\<\/\w+\>/.match(str)
  end
end
