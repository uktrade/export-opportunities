require 'rails_helper'

RSpec.describe Enquiry, type: :model do
  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:company_name) }
  it { is_expected.to validate_presence_of(:company_address) }
  it { is_expected.to validate_presence_of(:company_postcode) }
  it { is_expected.to validate_presence_of(:existing_exporter) }
  it { is_expected.to validate_presence_of(:company_sector) }
  it { is_expected.to validate_presence_of(:company_explanation) }

  it 'stores all enquiry information' do
    user = create(:user)
    opportunity = create(:opportunity)

    enquiry = Enquiry.create(
      first_name: 'John',
      last_name: 'Doe',
      company_telephone: '07123456789',
      company_name: 'Greenhouse Inc',
      company_address: '1 Gold Road',
      company_house_number: '0986718',
      company_postcode: 'a00a20',
      company_url: 'www.evil.com',
      existing_exporter: 'Not yet',
      company_sector: 'Airports',
      company_explanation: 'We are a valid company',
      opportunity: opportunity,
      user: user
    )

    expect(enquiry.first_name).to eql('John')
    expect(enquiry.last_name).to eql('Doe')
    expect(enquiry.company_telephone).to eql('07123456789')
    expect(enquiry.company_name).to eql('Greenhouse Inc')
    expect(enquiry.company_address).to eql('1 Gold Road')
    expect(enquiry.company_house_number).to eq('0986718')
    expect(enquiry.company_postcode).to eql('a00a20')
    expect(enquiry.company_url).to eql('http://www.evil.com')
    expect(enquiry.existing_exporter).to eql('Not yet')
    expect(enquiry.company_sector).to eql('Airports')
    expect(enquiry.company_explanation).to eql('We are a valid company')
    expect(enquiry.opportunity).to eq(opportunity)
    expect(enquiry.user).to eq(user)
  end

  describe '#new_from_sso' do
    before do
      @user = create(:user)
      @opportunity = create(:opportunity)
      @sector = create(:sector)
    end

    it 'creates a valid enquiry with no sso cookie' do
      allow(DirectorySsoApiClient).to receive(:user_data){ nil }
      allow(DirectoryApiClient).to receive(:private_company_data){ nil }

      enquiry = Enquiry.new_from_sso(nil)
      # company_name, company_address, company_postcode, company_house_number
      # can be added by users in the form, if they are individual
      enquiry.assign_attributes(
        opportunity: @opportunity,
        user: @user,
        company_name: 'debug',
        company_address: 'debug',
        company_postcode: 'debug',
        company_house_number: 'debug',
        company_explanation: 'debug',
        existing_exporter: 'Not yet',
        company_sector: @sector.slug
      )
      expect(enquiry).to be_valid
    end

    it 'creates a valid enquiry when not receiving data from SSO' do
      allow(DirectorySsoApiClient).to receive(:user_data){ nil }
      allow(DirectoryApiClient).to receive(:private_company_data){ nil }

      enquiry = Enquiry.new_from_sso('')
      # company_name, company_address, company_postcode, company_house_number
      # can be added by users in the form, if they are individual
      enquiry.assign_attributes(
        opportunity: @opportunity,
        user: @user,
        company_name: 'debug',
        company_address: 'debug',
        company_postcode: 'debug',
        company_house_number: 'debug',
        company_explanation: 'debug',
        existing_exporter: 'Not yet',
        company_sector: @sector.slug
      )
      expect(enquiry).to be_valid
    end

    it 'creates a valid enquiry for individual' do
      allow(DirectorySsoApiClient).to receive(:user_data){{
        id: 1,
        email: "john@example.com",
        hashed_uuid: "88f9f63c93cd30c9a471d80548ef1d4552c5546c9328c85a171f03a8c439b23e",
        user_profile: { 
          first_name: "John",  
          last_name: "Bull",  
          job_title: "Owner",  
          mobile_phone_number: "123123123"
        }
      }}
      allow(DirectoryApiClient).to receive(:private_company_data){{
        'name': 'Joe Construction',
        'mobile_number': '5551234',
        'address_line_1': '123 Joe house',
        'address_line_2': 'Joe Street',
        'country': 'Uk',
        'postal_code': 'N1 4DF',
        'number': '12341234',
        'website': 'www.example.com',
        'summary': 'good company',
        'company_type': '' 
      }}

      enquiry = Enquiry.new_from_sso('')
      enquiry.assign_attributes(
        opportunity: @opportunity,
        user: @user,
        company_name: 'debug',
        company_address: 'debug',
        company_postcode: 'debug',
        company_house_number: 'debug',
        company_explanation: 'debug',
        existing_exporter: 'Not yet',
        company_sector: @sector.slug
      )
      expect(enquiry).to be_valid
    end

    it 'creates a valid enquiry for individual with limited data' do
      allow(DirectorySsoApiClient).to receive(:user_data){{
        id: nil,
        email: "",
        hashed_uuid: "",
        user_profile: { 
          first_name: "",  
          last_name: "",  
          job_title: "",  
          mobile_phone_number: ""
        }
      }}
      allow(DirectoryApiClient).to receive(:private_company_data){{
        'name': '',
        'mobile_number': '',
        'address_line_1': '',
        'address_line_2': '',
        'country': '',
        'postal_code': '',
        'number': '',
        'website': '',
        'summary': '',
        'company_type': '' 
      }}

      enquiry = Enquiry.new_from_sso('')
      # company_name, company_address, company_postcode, company_house_number
      # can be added by users in the form, if they are individual
      enquiry.assign_attributes(
        opportunity: @opportunity,
        user: @user,
        company_name: 'debug',
        company_address: 'debug',
        company_postcode: 'debug',
        company_house_number: 'debug',
        company_explanation: 'debug',
        existing_exporter: 'Not yet',
        company_sector: @sector.slug
      )
      expect(enquiry).to be_valid
    end

    it 'creates a valid enquiry for a company' do
      allow(DirectorySsoApiClient).to receive(:user_data){{
        id: 1,
        email: "john@example.com",
        hashed_uuid: "88f9f63c93cd30c9a471d80548ef1d4552c5546c9328c85a171f03a8c439b23e",
        user_profile: { 
          first_name: "John",  
          last_name: "Bull",  
          job_title: "Owner",  
          mobile_phone_number: "123123123"
        }
      }}
      allow(DirectoryApiClient).to receive(:private_company_data){{
        'name': 'Joe Construction',
        'mobile_number': '5551234',
        'address_line_1': '123 Joe house',
        'address_line_2': 'Joe Street',
        'country': 'Uk',
        'postal_code': 'N1 4DF',
        'number': '12341234',
        'website': 'www.example.com',
        'summary': 'good company',
        'company_type': 'COMPANIES_HOUSE' 
      }}

      enquiry = Enquiry.new_from_sso('')
      enquiry.assign_attributes(
        opportunity: @opportunity,
        user: @user,
        existing_exporter: 'Not yet',
        company_sector: @sector.slug
      )
      expect(enquiry).to be_valid
    end

    it 'creates a valid enquiry for a company with limited data' do
      allow(DirectorySsoApiClient).to receive(:user_data){{
        id: nil,
        email: "",
        hashed_uuid: "",
        user_profile: { 
          first_name: "",  
          last_name: "",  
          job_title: "",  
          mobile_phone_number: ""
        }
      }}
      allow(DirectoryApiClient).to receive(:private_company_data){{
        'email_full_name': '',
        'name': '',
        'mobile_number': '',
        'address_line_1': '',
        'address_line_2': '',
        'country': '',
        'postal_code': '',
        'number': '',
        'website': '',
        'summary': '',
        'company_type': 'COMPANIES_HOUSE'
      }}

      enquiry = Enquiry.new_from_sso('')
      enquiry.assign_attributes(
        opportunity: @opportunity,
        user: @user,
        company_explanation: 'Good company',
        existing_exporter: 'Not yet',
        company_sector: @sector.slug
      )
      expect(enquiry).to be_valid
    end
  end

  describe '#company_url' do
    it 'returns the url' do
      enquiry = create(:enquiry, company_url: 'https://example.com')
      expect(enquiry.company_url).to eql('https://example.com')
    end

    context 'when a protocol was not provided' do
      it 'returns an absolute url with `http` as the protocol' do
        enquiry = create(:enquiry, company_url: 'example.com')
        expect(enquiry.company_url).to eql('http://example.com')
      end
    end

    context 'when only the `www` subdomain was provided' do
      it 'returns an absolute url with `http` as the protocol' do
        enquiry = create(:enquiry, company_url: 'www.example.com')
        expect(enquiry.company_url).to eql('http://www.example.com')
      end
    end

    context 'with multiple web sites in the provided input' do
      it 'returns the original unmodified URL string' do
        enquiry = create(:enquiry, company_url: 'www.example.net / www.example.org')

        expect(enquiry.company_url).to eql('www.example.net / www.example.org')
      end
    end
  end
end
