require 'rails_helper'

describe Admin::EnquiryResponsesController, type: :controller do
  before :each do
    sign_in(create(:user))
  end

  describe '#create' do
    let(:opportunity) { create(:opportunity) }
    let(:enquiry) { create(:enquiry) }
    let(:enquiry_response) { create(:enquiry_response) }

    it 'creates an enquiry response' do
      # enquiry_response = post :create, enquiry: attributes_for(:enquiry), enquiry_response: attributes_for(:enquiry_response)
      # expect(enquiry_response).to render_template(:create)
      # expect(assigns(:enquiry)).to eq(Enquiry.last)
      # expect(assigns(:enquiry).opportunity).to eq(opportunity)
    end
  end
end
