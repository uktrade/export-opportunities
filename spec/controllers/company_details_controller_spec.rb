require 'rails_helper'
require 'json'

RSpec.describe CompanyDetailsController, type: :controller do
  describe '#index' do
    it 'retrieves results from the API' do
      company_detail = build(:company_detail)
      allow_any_instance_of(CompanyHouseFinder).to receive(:call).and_return([company_detail])
      response = get :index, search: 'Dxw Ltd'

      expect(response.content_type).to eql('application/json')
      data = JSON.parse(response.body)
      expect(data[0]['name']).to eql company_detail.name
      expect(data[0]['number']).to eql company_detail.number
      expect(data[0]['postcode']).to eql company_detail.postcode
    end

    it 'returns an array of company details' do
      company_detail = build(:company_detail)
      allow_any_instance_of(CompanyHouseFinder).to receive(:call).and_return([company_detail])
      get :index, search: 'Dxw Ltd'

      expect(assigns(:results).first).to eq company_detail
    end

    context 'query is empty' do
      it 'should return empty' do
        get :index, search: ''
        expect(assigns(:results)).to be_empty
      end
    end
  end
end
