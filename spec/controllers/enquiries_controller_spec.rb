require 'rails_helper'

RSpec.describe EnquiriesController, type: :controller do
  before :each do
    sign_in(create(:user))
  end

  describe '#new' do
    let(:opportunity) { create(:opportunity, status: :publish) }
    it 'assigns opportunities' do
      get :new, slug: opportunity.slug
      expect(assigns(:opportunity)).to eq(opportunity)
    end

    it 'assigns enquiry' do
      get :new, slug: opportunity.slug
      expect(assigns(:enquiry)).not_to be_nil
    end

    it 'raises a 404 if the opportunity was not found' do
      get :new, slug: 'this-doesnt-exist'
      expect(response.status).to eq 404
    end
  end

  describe '#create' do
    let(:opportunity) { create(:opportunity) }

    it 'creates an enquiry' do
      response = post :create, enquiry: attributes_for(:enquiry), slug: opportunity.slug
      expect(response).to render_template(:create)
      expect(assigns(:enquiry)).to eq(Enquiry.last)
      expect(assigns(:enquiry).opportunity).to eq(opportunity)
    end

    it "doesn't create an enquiry if params not there" do
      params = { first_name: nil }
      response = post :create, enquiry: params, slug: opportunity.slug
      expect(assigns(:enquiry)).not_to be_nil
      expect(assigns(:enquiry).id).to be_nil
      expect(assigns(:opportunity)).to eq(opportunity)
      expect(response).to render_template(:new)
    end

    it 'raises a 404 if the opportunity was not found' do
      post :create, enquiry: attributes_for(:enquiry), slug: 'this-doesnt-exist'
      expect(response.status).to eq 404
    end
  end
end
