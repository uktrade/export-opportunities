require 'rails_helper'
require 'capybara/email/rspec'

RSpec.feature 'User can give feedback' do
  scenario 'receives an email' do
    opp = create(:opportunity, title: 'France - Cow required')
    user = create(:user, email: 'test@example.com')
    enquiry = create(:enquiry, opportunity: opp, user: user)

    EnquiryFeedbackSender.new.call(enquiry)

    open_email('test@example.com')

    expect(current_email.subject).to eq 'Help us improve the Export Opportunities service'
    expect(current_email).to have_content(opp.title)
  end

  scenario 'clicking each of the feedback links' do
    options = [
      'I won or expect to win business',
      'I didn’t win business',
      'I can’t remember',
      'I haven’t had a reply',
    ]

    opp = create(:opportunity)
    user = create(:user, email: 'test@example.com')

    options.each do |option|
      enquiry = create(:enquiry, opportunity: opp, user: user)

      EnquiryFeedbackSender.new.call(enquiry)

      open_email('test@example.com')
      current_email.click_on option

      expect(page).to have_content('Thanks for your feedback on Export Opportunities')

      clear_emails
    end
  end
end
