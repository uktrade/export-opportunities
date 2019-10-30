require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe 'routing' do
    it 'check endpoint is publically accessible' do
      expect(get: '/export-opportunities/check').to route_to(controller: 'application', action: 'check')
    end

    it 'api check endpoint is publically accessible' do
      expect(get: '/export-opportunities/api_check').to route_to(controller: 'application', action: 'api_check')
    end
  end

  describe 'require_sso!', focus: true do
    let(:opportunity) { create(:opportunity, status: :publish) }
    
    before do
      @controller = EnquiriesController.new
      @directory_sso_api_url = Figaro.env.DIRECTORY_SSO_API_DOMAIN + '/api/v1/session-user/?session_key=1'
    end

    it 'returns true when user is logged in and has passed registration journey' do
      sign_in(create(:user))
      cookies[Figaro.env.SSO_SESSION_COOKIE] = '1'
      stub_request(:get, @directory_sso_api_url).to_return(body: {
        id: 1,
        email: "john@example.com",
        hashed_uuid: "88f9f63c93cd30c9a471d80548ef1d4552c5546c9328c85a171f03a8c439b23e",
        user_profile: { 
          first_name: "John",  
          last_name: "Bull",  
          job_title: "Owner",  
          mobile_phone_number: "123123123"
        }
      }
      .to_json, status: 200)

      get :new, params: { slug: opportunity.slug }
      expect(response.status).to eq 200
    end
    it 'redirects when user is not logged in' do
      cookies[Figaro.env.SSO_SESSION_COOKIE] = '1'
      stub_request(:get, @directory_sso_api_url).to_return(status: 404)
      get :new, params: { slug: opportunity.slug }
      expect(response.status).to eq 302
    end
    it 'redirects when user is logged in but has not passed registration journey' do
      # user_profile will be missing
      sign_in(create(:user))
      cookies[Figaro.env.SSO_SESSION_COOKIE] = '1'
      stub_request(:get, @directory_sso_api_url).to_return(body: {
        id: 1,
        email: "john@example.com",
        hashed_uuid: "88f9f63c93cd30c9a471d80548ef1d4552c5546c9328c85a171f03a8c439b23e",
        user_profile: {}
      }
      .to_json, status: 200)

      get :new, params: { slug: opportunity.slug }
      expect(response.status).to eq 302
    end
  end
end
