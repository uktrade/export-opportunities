require 'rails_helper'

RSpec.describe Api::ProfileDashboardController, type: :controller do
  describe 'GET profile dashboard info' do
    context 'with a SUD user' do

      it 'fetches information' do
        user = create(:user)
        country = create(:country)
        subscription = create(:subscription, user_id: user.id, countries: [country])
        get :index, params: { format: :json, hashed_sso_id: user.sso_hashed_uuid, shared_secret: Figaro.env.api_profile_dashboard_shared_secret }

        json_response = JSON.parse(response.body)

        expect(response).to have_http_status(200)
        expect(response.body).to include('"status":"ok"')
        expect(json_response['email_alerts'][0]['title']).to include(subscription.search_term)
        expect(json_response['email_alerts'][0]['countries']).to include(country.slug)
      end
    end
  end

  describe 'GET relevant opportunities' do
    context 'with a SUD user' do

      it 'fetches information' do
        user = create(:user)
        opportunity = create(:opportunity, status: :publish)
        refresh_elasticsearch
        get :opportunities, params: { format: :json, hashed_sso_id: user.sso_hashed_uuid, shared_secret: Figaro.env.api_profile_dashboard_shared_secret }

        json_response = JSON.parse(response.body)

        expect(response).to have_http_status(200)
        expect(response.body).to include('"status":"ok"')
        expect(json_response['relevant_opportunities'][0]['title']).to include(opportunity.title)
      end
    end
  end
end
