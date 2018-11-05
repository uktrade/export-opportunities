require 'rails_helper'

feature 'users can submit feedback after impact email has been sent to them' do
  scenario 'a user clicks on the I won this opportunity link in the impact email, lands in our feedback form page and submits feedback' do
    content = get_content('enquiry_feedback')
    feedback = create(:enquiry_feedback)
    params = { id: feedback.id, response: :won }
    feedback_message = 'some user feedback'

    expect(EncryptedParams).to receive(:decrypt).with(nil).and_return(params)
    visit enquiry_feedback_url(params[:id])
    feedback.reload

    expect(page).to have_content content['response_breadcrumb']
    fill_in 'enquiry_feedback[message]', with: feedback_message
    click_on content['response_submit']
    feedback.reload

    expect(feedback).to be_won
    expect(feedback.responded_at).not_to be_nil
    expect(feedback.message).to eq(feedback_message)
  end
end
