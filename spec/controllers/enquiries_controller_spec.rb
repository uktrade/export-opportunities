require 'rails_helper'

RSpec.describe EnquiriesController, type: :controller do
  before :each do
    sign_in(create(:user))
  end

  describe '#new' do
    let(:opportunity) { create(:opportunity, status: :publish) }
    it 'assigns opportunities' do
      get :new, params: { slug: opportunity.slug }
      expect(assigns(:opportunity)).to eq(opportunity)
    end

    it 'assigns enquiry' do
      get :new, params: { slug: opportunity.slug }
      expect(assigns(:enquiry)).not_to be_nil
    end

    it 'assigns enquiry from data from directory-api if available' do
      directory_api_url = Figaro.env.DIRECTORY_API_DOMAIN + '/supplier/company/'
      cookies[Figaro.env.SSO_SESSION_COOKIE] = '1'
      stub_request(:get, directory_api_url).to_return(body: {
        email_full_name: 'Mr Bull',
        mobile_number: '555 12345',
        name: 'John Bull Construction',
        address_line_1: '123 Letsbe Avenue',
        address_line_2: 'London',
        country: 'UK',
        number: '11111111',
        postal_code: 'N1 4DR',
        website: 'www.example.com',
        has_exported_before: 'true',
        sectors: ['Construction'],
        summary: 'Good company',
        company_type: 'COMPANIES_HOUSE'
      }.to_json, status: 200)

      directory_sso_api_url = Figaro.env.DIRECTORY_SSO_API_DOMAIN + '/api/v1/session-user/?session_key=1'
      stub_request(:get, directory_sso_api_url).to_return(body: {
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
      enquiry = assigns(:enquiry)
      expect(enquiry).not_to be_nil
      expect(enquiry.first_name).to eq "John"
      expect(enquiry.last_name).to eq "Bull"
      expect(enquiry.job_title).to eq "Owner"
      expect(enquiry.company_telephone).to eq '123123123'
      expect(enquiry.company_name).to eq 'John Bull Construction'
      expect(enquiry.company_address).to eq '123 Letsbe Avenue London UK'
      expect(enquiry.company_house_number).to eq '11111111'
      expect(enquiry.company_postcode).to eq 'N1 4DR'
      expect(enquiry.company_url).to eq 'http://www.example.com'
      expect(enquiry.company_explanation).to eq 'Good company'
      expect(enquiry.account_type).to eq 'COMPANIES_HOUSE'
    end

    it 'raises a 404 if the opportunity was not found' do
      get :new, params: { slug: 'this-doesnt-exist' }
      expect(response.status).to eq 404
    end
  end

  describe '#create' do
    let(:opportunity) { create(:opportunity) }

    it 'creates an enquiry' do
      response = post :create, params: { enquiry: attributes_for(:enquiry), slug: opportunity.slug }
      expect(response).to render_template(:create)
      expect(assigns(:enquiry)).to eq(Enquiry.last)
      expect(assigns(:enquiry).opportunity).to eq(opportunity)
    end

    it "doesn't create an enquiry if params not there" do
      params = { first_name: nil }
      response = post :create, params: { enquiry: params, slug: opportunity.slug }
      expect(assigns(:enquiry)).not_to be_nil
      expect(assigns(:enquiry).id).to be_nil
      expect(assigns(:opportunity)).to eq(opportunity)
      expect(response).to render_template(:new)
    end

    it 'raises a 404 if the opportunity was not found' do
      post :create, params: { enquiry: attributes_for(:enquiry), slug: 'this-doesnt-exist' }
      expect(response.status).to eq 404
    end
  end
end
