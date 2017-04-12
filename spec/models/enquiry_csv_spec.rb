require 'rails_helper'

describe EnquiryCSV do
  describe '#each' do
    it 'yields the CSV header, even when there are no enquiries' do
      expect { |row| subject.each(&row) }.to yield_with_args(expected_header)
    end

    it 'yields the CSV header and then the rows in turn' do
      service_provider = create(:service_provider, name: 'France Paris')
      countries = [create(:country, name: 'France')]
      opportunity = create(:opportunity, title: 'France - shoes needed', service_provider: service_provider, countries: countries)
      user = create(:user, email: 'peppa@pig.com')

      enquiry = create(
        :enquiry,
        opportunity: opportunity,
        first_name: 'Peppa',
        last_name: 'Pig',
        company_address: 'Victoria Street',
        company_explanation: "We would like to\nexport.",
        company_house_number: '1234',
        company_name: 'Pig Ltd',
        company_postcode: 'AB1 1BA',
        company_telephone: '01234 567890',
        company_url: 'http://pig.com/',
        created_at: '2017-01-17 12:00:00',
        company_sector: 'Agriculture',
        user: user,
        existing_exporter: 'Not yet',
        data_protection: true
      )

      expected_row = "Pig Ltd,Peppa,Pig,Victoria Street,AB1 1BA,01234 567890,2017/01/17 12:00,Agriculture,France - shoes needed,France,peppa@pig.com,France Paris,Yes,N/A,#{enquiry.opportunity_id},1234,http://pig.com/,Not yet,\"We would like to\nexport.\"\n"

      expect { |row| subject.each(&row) }.to yield_successive_args(expected_header, expected_row)
    end

    it 'yields correctly even with a worse-minimally-completed enquiry' do
      create(:country)
      opportunity = build(:opportunity, service_provider: nil, title: 'Germany - sausages needed')
      opportunity.save(validate: false)
      user = create(:user, email: 'peppa@pig.com')

      enquiry = create(
        :enquiry,
        opportunity: opportunity,
        first_name: 'Peppa',
        last_name: 'Pig',
        company_address: 'Victoria Street',
        company_explanation: "We would like to\nexport.",
        company_house_number: '1234',
        company_name: 'Pig Ltd',
        company_postcode: 'AB1 1BA',
        company_telephone: '01234 567890',
        company_url: 'http://pig.com/',
        created_at: '2017-01-17 12:00:00',
        company_sector: 'Agriculture',
        user: user,
        existing_exporter: 'Not yet',
        data_protection: true
      )

      expected_row = "Pig Ltd,Peppa,Pig,Victoria Street,AB1 1BA,01234 567890,2017/01/17 12:00,Agriculture,Germany - sausages needed,,peppa@pig.com,,Yes,N/A,#{enquiry.opportunity_id},1234,http://pig.com/,Not yet,\"We would like to\nexport.\"\n"

      expect { |row| subject.each(&row) }.to yield_successive_args(expected_header, expected_row)
    end
  end

  def expected_header
    "Company Name,First Name,Last Name,Company Address,Company Postcode,Company Telephone number,Date response submitted,Company's Sector,Opportunity Title,Countries,Email Address,Service provider,Terms accepted,webUserId,Opportunity ID,Companies House Number,Company URL,Have they sold products or services to overseas customers?,How the company can meet the requirements in this opportunity\n"
  end
end
