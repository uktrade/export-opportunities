require 'spec_helper'
require 'app/services/company_house_finder'

RSpec.describe CompanyHouseFinder, type: :service do
  COMPANIES_HOUSE_API_MATCHER = %r{\Ahttps://\w*:?@?api.companieshouse.gov.uk/search/companies?.+}.freeze

  subject { described_class.new }

  describe '#call' do
    it 'should take search_terms' do
      expect(subject).to receive(:call).with('dxw')
      subject.call('dxw')
    end

    it 'should return an array of Company Details' do
      stub_api_call('items' => [example_company_house_response])
      result = subject.call('dxw')
      expect(result).to be_kind_of(Array)
      expect(result.first).to be_kind_of(CompanyDetail)
    end

    it 'returns company details' do
      stub_api_call(items: [example_company_house_response])

      result = subject.call('dxw')

      expect(result.first.number).to eql('09421914')
      expect(result.first.postcode).to eql('W1U 8EW')
      expect(result.first.name).to eql('DXW LTD')
    end
  end

  context 'when the API returns unexpected data' do
    it 'returns an empty string/nil result' do
      stub_request(:get, COMPANIES_HOUSE_API_MATCHER).to_return(status: 200, body: '')
      expect(Rails.logger).to receive(:warn)
      expect(subject.call('foo')).to eq([])
    end

    it 'returns no results' do
      stub_request(:get, COMPANIES_HOUSE_API_MATCHER).to_return(status: 200, body: JSON.generate({}))
      expect(Rails.logger).to receive(:warn)
      expect(subject.call('foo')).to eq([])
    end

    it 'returns an invalid status code' do
      stub_request(:get, COMPANIES_HOUSE_API_MATCHER).to_return(status: 500, body: JSON.generate({}))
      expect(Rails.logger).to receive(:warn)
      expect(subject.call('foo')).to eq([])
    end
  end

  describe '.search_companies' do
    it 'should make a request to the API' do
      stub_api_call
      expect(subject).to receive(:search_companies)
      subject.call('dxw')
    end
  end

  def stub_api_call(result_body = {})
    result = { items_per_page: 50,
               items: [],
               kind: 'search#companies',
               total_results: 0,
               page_number: 1,
               start_index: 0 }.with_indifferent_access
    result.merge!(result_body)
    stub_request(:get, COMPANIES_HOUSE_API_MATCHER).to_return(status: 200, body: JSON.generate(result))
  end

  def example_company_house_response
    {
      'links' => { 'self' => '/company/09421914' },
      'company_type' => 'ltd',
      'address' => { 'locality' => 'London', 'address_line_1' => '55 Baker Street 55 Baker Street', 'postal_code' => 'W1U 8EW', 'address_line_2' => 'Floor 7' },
      'kind' => 'searchresults#company',
      'description_identifier' => ['incorporated-on'],
      'description' => '09421914 - Incorporated on  4 February 2015',
      'matches' => { 'title' => [1, 3] },
      'company_status' => 'active',
      'snippet' => '55 Baker Street 55 Baker Street, Floor 7, London, W1U 8EW',
      'date_of_creation' => '2015-02-04',
      'company_number' => '09421914',
      'title' => 'DXW LTD',
    }.with_indifferent_access
  end
end
