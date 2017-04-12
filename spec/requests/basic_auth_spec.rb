require 'rails_helper'

RSpec.describe 'Basic auth', type: :request do
  PUBLIC_VIEW_ROUTES = [
    '/',
    '/opportunities.atom',
    '/opportunities/foo-bar',
    '/company_details',
    '/subscriptions',
    '/pending_subscriptions',
    '/country/france',
    '/industry/cheese',
    '/sector/public-sector',
    '/value/over-100k',
  ].freeze

  ADMIN_VIEW_ROUTES = [
    '/admin/opportunities',
    '/admin/opportunities/downloads',
    '/admin/opportunities/new',
    '/admin/opportunities/123456792348578234758/',
    '/admin/opportunities/123456792348578234758/edit',
    '/admin/enquiries',
    '/admin/enquiries/123456792348578234758',
    '/admin/editors',
    '/admin/editors/1',
    '/admin/editors/1/edit',
    '/admin/editors/sign_in',
    '/admin/editors/password/new',
    '/admin/editors/password/edit',
    '/admin/editor/confirmation?confirmation_token=abcdef',
  ].freeze

  V1API_ROUTES = [
    '/v1/subscriptions/1234192837498127349871',
    '/v1/opportunities/182391827381',
    '/v1/subscriptions/unsubscribe/172381278hj88u',
  ].freeze

  V1API_LOGIN_ROUTES = [
    '/v1/subscriptions/unsubscribe/',
  ].freeze

  context 'in production' do
    before do
      fake_env = double.as_null_object
      allow(Figaro).to receive(:env).and_return(fake_env)
      allow(fake_env).to receive(:staging_http_user?).and_return(false)
      allow(fake_env).to receive(:staging_http_pass?).and_return(false)
      allow(fake_env).to receive(:staging_http_user).and_return(nil)
      allow(fake_env).to receive(:staging_http_pass).and_return(nil)
      allow(fake_env).to receive(:enquiry_endpoint_token).and_return('fake_token')
    end

    (PUBLIC_VIEW_ROUTES + ADMIN_VIEW_ROUTES).each do |route|
      it "responds successfully to GET #{route}" do
        get route
        expect(response.status).not_to eq(401)
      end
    end

    V1API_ROUTES.each do |route|
      it "responds successfully to GET #{route}" do
        mock_sso_with(email: Faker::Internet.email)

        get route
        expect(response.status).not_to eq(401)
      end
    end

    V1API_LOGIN_ROUTES.each do |route|
      it "responds successfully to GET #{route}" do
        email = Faker::Internet.email
        mock_sso_with(email: email)
        user = create(:user, email: email)
        subscription = create(:subscription, user: user)

        sign_in user

        get route << subscription.id
        expect(response.status).not_to eq(401)
      end
    end

    it 'should always return 200 on /check' do
      get '/check'
      expect(response.status).to eq(200)
    end
  end

  context 'in staging' do
    before do
      fake_env = double.as_null_object
      allow(Figaro).to receive(:env).and_return(fake_env)
      allow(fake_env).to receive(:staging_http_user?).and_return(true)
      allow(fake_env).to receive(:staging_http_pass?).and_return(true)
      allow(fake_env).to receive(:staging_http_user).and_return('username')
      allow(fake_env).to receive(:staging_http_pass).and_return('password')
      allow(fake_env).to receive(:enquiry_endpoint_token).and_return('fake_token')
    end

    (PUBLIC_VIEW_ROUTES + ADMIN_VIEW_ROUTES).each do |route|
      it "requests basic auth credentials for GET #{route}" do
        get route
        public_send(:get, route)
        expect(response.status).to eq(401)
      end
    end

    it 'should always return 200 on /check' do
      get '/check'
      expect(response.status).to eq(200)
    end
  end
end
