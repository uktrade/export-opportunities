require 'rails_helper'
require 'capybara/email/rspec'

RSpec.feature 'User can give feedback to the impact email' do
  let(:content) { get_content('enquiry_feedback') }

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
      content['won'],
      content['did_not_win'],
      content['dont_know_outcome'],
      content['no_response'],
    ]

    opp = create(:opportunity)
    user = create(:user, email: 'test@example.com')

    options.each do |option|
      enquiry = create(:enquiry, opportunity: opp, user: user)

      EnquiryFeedbackSender.new.call(enquiry)

      open_email('test@example.com')
      current_email.click_link option

      expect(page).to have_content content['response_title']
      expect(page).to have_content content['response_instruction']

      clear_emails
    end
  end
end
