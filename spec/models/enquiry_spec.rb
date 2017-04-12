require 'rails_helper'

RSpec.describe Enquiry, type: :model do
  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:company_telephone) }
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

  describe '#initialize_from_existing' do
    it 'returns a prepopulated Enquiry when an existing enquiry is passed' do
      old_enquiry = create :enquiry,
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
        company_explanation: 'The first of many enquiries we will make',
        opportunity: create(:opportunity),
        user: create(:user)

      new_enquiry = Enquiry.initialize_from_existing(old_enquiry)
      expect(new_enquiry.first_name).to eq 'John'
      expect(new_enquiry.last_name).to eq 'Doe'
      expect(new_enquiry.company_telephone).to eq '07123456789'
      expect(new_enquiry.company_name).to eq 'Greenhouse Inc'
      expect(new_enquiry.company_address).to eq '1 Gold Road'
      expect(new_enquiry.company_house_number).to eq '0986718'
      expect(new_enquiry.company_postcode).to eq 'a00a20'
      expect(new_enquiry.company_url).to eq 'http://www.evil.com'
      expect(new_enquiry.existing_exporter).to eq 'Not yet'
      expect(new_enquiry.company_sector).to eq 'Airports'

      expect(new_enquiry.company_explanation).to be_blank
    end

    it 'returns a normal, empty Enquiry record when no enquiry is passed' do
      user = create(:user)
      expect(user.enquiries).to be_empty

      enquiry = Enquiry.initialize_from_existing(nil)
      expect(enquiry.attributes).to eq(Enquiry.new.attributes)
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
