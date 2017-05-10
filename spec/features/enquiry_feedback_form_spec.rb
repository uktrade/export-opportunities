require 'rails_helper'

feature 'users can submit feedback after impact email has been sent to them' do
  scenario 'a user clicks on the I won this opportunity link in the impact email, lands in our feedback form page and submits feedback' do
    feedback = create(:enquiry_feedback)
    params = { id: feedback.id, response: :won }
    feedback_message = Faker::Lorem.sentence(10, false, 5)

    expect(EncryptedParams).to receive(:decrypt).with(nil).and_return(params)
    visit enquiry_feedback_url(params[:id])
    feedback.reload
    fill_in 'Feedback', with: feedback_message
    click_on 'Submit'
    feedback.reload

    expect(feedback).to be_won
    expect(feedback.responded_at).not_to be_nil
    expect(feedback.message).to eq(feedback_message)
  end
end
