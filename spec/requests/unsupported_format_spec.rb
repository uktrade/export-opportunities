require 'rails_helper'

RSpec.describe 'unsupported formats' do
  before(:each) { create(:opportunity, :published, slug: 'future-days') }

  context 'on an opportunity page' do
    it 'returns a 406 for json' do
      get '/export-opportunities/opportunities/future-days.json'
      expect(response).to have_http_status(406)
      expect(response.header['Content-Type']).to include 'application/json'
      expect(JSON.parse(response.body)).to eq('errors' => 'JSON is not supported for this resource')
    end

    it 'returns a 406 for xml' do
      skip('Rails 5')
      get '/export-opportunities/opportunities/future-days.xml'
      expect(response).to have_http_status(406)
      expect(response.header['Content-Type']).to include 'application/xml'
      expect(response.body).to be_empty
    end

    it 'returns a 406 for unknown formats' do
      get '/export-opportunities/opportunities/future-days.wibble'
      expect(response).to have_http_status(406)
      expect(response.body).to be_empty
    end
  end
end
