require 'rails_helper'

RSpec.describe Users::EnquiriesController, sso: true do
  describe '#show' do
    it 'returns a 404 if the requested enquiry belongs to another user' do
      user = create(:user, email: 'me@example.com')
      sign_in user

      opportunity = create(:opportunity, :published)
      other_user = create(:user, email: 'other@example.com')
      enquiry = create(:enquiry, user: other_user, opportunity: opportunity)

      get :show, params: { id: enquiry.id }

      expect(response).to have_http_status(:not_found)
    end
  end
end
