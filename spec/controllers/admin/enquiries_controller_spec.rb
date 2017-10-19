require 'rails_helper'

describe Admin::EnquiriesController, type: :controller do
  let(:opportunity) { create(:opportunity) }
  let(:enquiry) { create(:enquiry) }
  let(:enquiry_response) { create(:enquiry_response) }

  describe '#next_enquiry' do
    login_editor(role: :admin)
    it 'gets next enquiry' do
      enquiry = create(:enquiry)
      create(:enquiry_response, enquiry: enquiry)

      get :index
    end
  end
end
