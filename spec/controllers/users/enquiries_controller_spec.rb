require 'rails_helper'

RSpec.describe Users::EnquiriesController do
  describe '#show', sso: true do
    it 'returns a 404 if the requested enquiry belongs to another user' do
      allow(DirectoryApiClient).to receive(:user_data){{
        id: 1,
        email: "john@example.com",
        hashed_uuid: "88f9f63c93cd30c9a471d80548ef1d4552c5546c9328c85a171f03a8c439b23e",
        user_profile: {
          first_name: "John",
          last_name: "Bull",
          job_title: "Owner",
          mobile_phone_number: "123123123"
        }
      }}

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
