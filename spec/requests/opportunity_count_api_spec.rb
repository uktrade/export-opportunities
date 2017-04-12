require 'rails_helper'

describe 'Viewing the number of opportunities', type: :request do
  describe 'successfully' do
    it 'returns the number of available opportunities as JSON' do
      create_list(:opportunity, 3, :published)

      create(:opportunity)
      create(:opportunity, :published, response_due_on: 1.month.ago)

      get '/v1/opportunities/count.json'
      expected_hash = { 'opportunities_count' => 3 }

      expect(response.status).to eql(200)
      expect(JSON.parse(response.body)).to include(expected_hash)
    end
  end
end
