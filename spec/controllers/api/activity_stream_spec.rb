require 'rails_helper'

RSpec.describe Api::ActivityStreamController, type: :controller do
  describe 'GET feed controller' do
    it 'responds with a 401 error if Authorization header is not set' do
      get :index, params: { format: :json }
      expect(response.status).to eq(401)
      expect(response.body).to eq(%({"message":"Authorization header is missing"}))
    end

    it 'responds with a blank JSON object if Authorization header is set' do
      @request.headers['Authorization'] = ''
      get :index, params: { format: :json }

      expect(response.body).to eq('{}')
      expect(response.headers['Content-Type']).to eq('application/activity+json')
    end
  end
end
