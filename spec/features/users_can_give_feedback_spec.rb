require 'rails_helper'
require 'capybara/email/rspec'

RSpec.feature 'User can give feedback to the impact email' do
  scenario 'receives an email' do
    opp = create(:opportunity, title: 'France - Cow required')
    user = create(:user, email: 'test@example.com')
    enquiry = create(:enquiry, opportunity: opp, user: user)

    EnquiryFeedbackSender.new.call(enquiry)

    open_email('test@example.com')

    expect(current_email.subject).to have_content('Give feedback on')
    expect(current_email.subject).to have_content(opp.title)
    expect(current_email).to have_content(opp.title)
  end

  scenario 'clicking each of the feedback links' do
    options = [
      'I was contacted by the buyer but don\'t yet know the outcome',
      'I won the business',
      'I didn\'t win the business',
      'I was contacted by the buyer but don\'t yet know the outcome',
      'I wasn\'t contacted by the buyer',
      'I don\'t know or I don\'t want to say',
    ]

    opp = create(:opportunity)
    user = create(:user, email: 'test@example.com')

    options.each do |option|
      enquiry = create(:enquiry, opportunity: opp, user: user)

      EnquiryFeedbackSender.new.call(enquiry)

      open_email('test@example.com')
      current_email.click_on option

      expect(page).to have_content('Thank you You selected:')

      clear_emails
    end
  end
end
