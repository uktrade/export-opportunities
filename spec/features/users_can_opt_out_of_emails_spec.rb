require 'rails_helper'
require 'capybara/email/rspec'

RSpec.feature 'Users can opt out of emails' do
  scenario 'by clicking a link in a feedback email' do
    user = create(:user, email: 'opt-out@example.com')
    enquiry = create(:enquiry, user: user)
    mock_sso_with(email: 'opt-out@example.com')

    EnquiryFeedbackSender.new.call(enquiry)
    open_email('opt-out@example.com')
    current_email.click_on 'Stop asking me for feedback on the export opportunities I apply for'

    expect(page).to have_content 'You will no longer receive requests for feedback'
  end
end
