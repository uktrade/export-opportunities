require 'rails_helper'
require 'capybara/email/rspec'

RSpec.describe EnquiryResponseLateMailer, type: :mailer, focus: true do

  it 'first_reminder' do
    enquiry = create(:enquiry)
    EnquiryResponseLateMailer.first_reminder(enquiry).deliver_now!

    mail = ActionMailer::Base.deliveries.last

    expect(mail.to).to include(enquiry.opportunity.author.email)
    expect(mail.subject).to eql("1st reminder: respond to enquiry")
    expect(mail.reply_to).to include(Figaro.env.CONTACT_US_EMAIL)
    expect(mail.parts.first.body.raw_source).to include('1st reminder: respond to enquiry')
  end

end

  # second_reminder
  #   to user
  #   subject "2nd reminder: respond to enquiry"
  #   reply_to Figaro.env.CONTACT_US_EMAIL (exportopportunities@) 'export_opportunites@inbox.com'
  #   cc  Figaro.env.late_response_support_inbox 'email@late_response_support.gov' 
  # notify_internal_team_of_late_responder
  #   to Figaro.env.late_response_notifications_inbox 'email@late_response_notifications.gov'
  #   subject "Response 21 days overdue"
  #   reply_to Figaro.env.export_opportunites_inbox (exportopportunities@) 
  # notify_internal_team_to_close_account_of_late_responder
  #   to Figaro.env.late_response_notifications_inbox 'email@late_response_notifications.gov'
  #   subject "Response 28 days overdue"
  #   reply_to Figaro.env.export_opportunites_inbox (exportopportunities@) 
