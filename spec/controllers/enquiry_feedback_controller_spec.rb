require 'rails_helper'

RSpec.describe EnquiryFeedbackController do
  describe '#new' do
    it 'updates the enquiry feedback record' do
      feedback = create(:enquiry_feedback)
      params = { id: feedback.id, response: :won }

      expect(EncryptedParams).to receive(:decrypt).with('encrypted string').and_return(params)
      get :new, q: 'encrypted string'
      feedback.reload

      expect(feedback).to be_won
      expect(feedback.responded_at).not_to be_nil
    end

    it 'updates the enquiry feedback record with every new click' do
      first_responded_at = 1.month.ago.round
      feedback = create(
        :enquiry_feedback,
        initial_response: :won,
        responded_at: first_responded_at
      )
      params = { id: feedback.id, response: :did_not_win }

      expect(EncryptedParams).to receive(:decrypt).with('encrypted string').and_return(params)
      get :new, q: 'encrypted string'

      feedback.reload

      expect(feedback).to be_did_not_win
      expect(feedback.responded_at).to_not eql first_responded_at
    end

    it 'provides an friendly but uninformative error if invalid' do
      get :new, q: 'incorrect string'

      expect(response).to have_http_status(:not_found)
    end
  end
end
