require 'rails_helper'

describe CompanyDetail, type: :model do
  it 'should return a postcode' do
    company_detail = CompanyDetail.new(address: { postal_code: 'W1U 8EW' })
    expect(company_detail.postcode).to eq 'W1U 8EW'
  end

  it 'should return a number' do
    company_detail = CompanyDetail.new(company_number: '123')
    expect(company_detail.number).to eq '123'
  end

  it 'should return a name' do
    company_detail = CompanyDetail.new(title: 'Dxw Ltd')
    expect(company_detail.name).to eq 'Dxw Ltd'
  end

  describe '#to_json' do
    it 'returns all fields as json' do
      company_detail = CompanyDetail.new(
        title: 'Dxw Ltd', company_number: 123, address: { postal_code: 'W1U 8EW' }
      )
      expect(company_detail.to_json).to eql('{"name":"Dxw Ltd","number":123,"postcode":"W1U 8EW"}')
    end
  end
end
