require 'rails_helper'
require 'capybara/email/rspec'

RSpec.feature 'Users can opt out of emails' do
  scenario 'by clicking a link in a feedback email' do
    user = create(:user, email: 'opt-out@example.com')
    enquiry = create(:enquiry, user: user)
    
    EnquiryFeedbackSender.new.call(enquiry)
    open_email('opt-out@example.com')
    current_email.click_on 'Unsubscribe'

    expect(page).to have_content 'You will no longer receive requests for feedback'
  end
end
