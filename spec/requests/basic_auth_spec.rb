require 'rails_helper'

RSpec.describe 'Basic auth', :elasticsearch, :commit, type: :request do
  PUBLIC_VIEW_ROUTES = [
    '/export-opportunities/',
    '/export-opportunities/opportunities.atom',
    '/export-opportunities/opportunities/foo-bar',
    '/export-opportunities/company_details',
    '/export-opportunities/subscriptions',
    '/export-opportunities/pending_subscriptions',
  ].freeze

  ADMIN_VIEW_ROUTES = [
    '/export-opportunities/admin/opportunities',
    '/export-opportunities/admin/opportunities/downloads',
    '/export-opportunities/admin/opportunities/new',
    '/export-opportunities/admin/opportunities/123456792348578234758/',
    '/export-opportunities/admin/opportunities/123456792348578234758/edit',
    '/export-opportunities/admin/enquiries',
    '/export-opportunities/admin/enquiries/123456792348578234758',
    '/export-opportunities/admin/editors',
    '/export-opportunities/admin/editors/1',
    '/export-opportunities/admin/editors/1/edit',
    '/export-opportunities/admin/editors/sign_in',
    '/export-opportunities/admin/editors/password/new',
    '/export-opportunities/admin/editors/password/edit',
    '/export-opportunities/admin/editor/confirmation?confirmation_token=abcdef',
  ].freeze

  V1API_ROUTES = [
    '/export-opportunities/v1/subscriptions/1234192837498127349871',
    '/export-opportunities/v1/opportunities/182391827381',
    '/export-opportunities/v1/subscriptions/unsubscribe/172381278hj88u',
  ].freeze

  V1API_LOGIN_ROUTES = [
    '/export-opportunities/v1/subscriptions/unsubscribe/',
  ].freeze

  context 'in production' do
    before do
      fake_env = double.as_null_object
      allow(Figaro).to receive(:env).and_return(fake_env)
      allow(fake_env).to receive(:OPPORTUNITY_ES_MAX_RESULT_WINDOW_SIZE).and_return(10000)
      allow(fake_env).to receive(:staging_http_user?).and_return(false)
      allow(fake_env).to receive(:staging_http_pass?).and_return(false)
      allow(fake_env).to receive(:staging_http_user).and_return(nil)
      allow(fake_env).to receive(:staging_http_pass).and_return(nil)
      allow(fake_env).to receive(:enquiry_endpoint_token).and_return('fake_token')
      allow(fake_env).to receive(:CONTACT_US_FORM).and_return(nil)
      allow(fake_env).to receive(:REDIS_URL).and_return(nil)
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
      get '/export-opportunities/check'
      expect(response.status).to eq(200)
    end

    it 'should always return 404 on /poc/international' do
      get '/export-opportunities/poc/international'
      expect(response.status).to eq(404)
    end

    it 'should always return 404 on /poc/opportunities/new' do
      get '/export-opportunities/poc/opportunities/new'
      expect(response.status).to eq(404)
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
      get '/export-opportunities/check'
      expect(response.status).to eq(200)
    end
  end
end
