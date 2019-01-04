require 'rails_helper'
require 'capybara/email/rspec'

RSpec.describe EnquiryResponseLateMailer, type: :mailer do

  it 'first_reminder'
    enquiry = create(:enquiry)
    enquiry_response = create(:enquiry_response, enquiry: enquiry, response_type: 1)

    EnquiryResponseLateMailer.right_for_opportunity(enquiry_response, enquiry_response.editor.email).deliver_now!

    mail = ActionMailer::Base.deliveries.last

    expect(mail.to).to include()
    expect(mail.subject).to eql("1st reminder: respond to enquiry")
    expect(mail.reply_to).to include(Figaro.env.CONTACT_US_EMAIL)
    expect(mail.parts.first.body.raw_source).to include('1st reminder: respond to enquiry')

    to user
    subject 
    reply_to  (exportopportunities@) 'export_opportunites@inbox.com'
    cc  Figaro.env.LATE_RESPONSE_SUPPORT_EMAIL 'email@late_response_support.gov' 
  

  second_reminder
    to user
    subject "2nd reminder: respond to enquiry"
    reply_to Figaro.env.CONTACT_US_EMAIL (exportopportunities@) 'export_opportunites@inbox.com'
    cc  Figaro.env.late_response_support_inbox 'email@late_response_support.gov' 
  notify_internal_team_of_late_responder
    to Figaro.env.late_response_notifications_inbox 'email@late_response_notifications.gov'
    subject "Response 21 days overdue"
    reply_to Figaro.env.export_opportunites_inbox (exportopportunities@) 
  notify_internal_team_to_close_account_of_late_responder
    to Figaro.env.late_response_notifications_inbox 'email@late_response_notifications.gov'
    subject "Response 28 days overdue"
    reply_to Figaro.env.export_opportunites_inbox (exportopportunities@) 


  describe '.send_enquiry_response without attachment' do
    it 'sends an enquiry response to the person creating the enquiry and the editor responding to it with response type 1 (right for opportunity)' do
      enquiry = create(:enquiry)
      enquiry_response = create(:enquiry_response, enquiry: enquiry, response_type: 1)

      EnquiryResponseMailer.right_for_opportunity(enquiry_response, enquiry_response.editor.email).deliver_now!

      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.subject).to eql("Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}")
      expect(last_delivery.to).to include(enquiry.user.email)
      expect(last_delivery.bcc).to include(enquiry_response.editor.email)
      expect(last_delivery.reply_to).to include(enquiry_response.editor.email)
      expect(last_delivery.parts.first.body.raw_source).to include('Your application will now move to the next stage.')
      expect(last_delivery.parts.first.body.raw_source).to include('Your application meets the criteria for this opportunity.')
    end

    it 'sends an enquiry response to the person creating the enquiry and the editor responding to it with response type 3 (NOT right for opportunity)' do
      enquiry = create(:enquiry)
      enquiry_response = create(:enquiry_response, enquiry: enquiry, response_type: 3)
      reply_to_address = 'noreply@noreply.net'

      EnquiryResponseMailer.not_right_for_opportunity(enquiry_response, enquiry_response.editor.email, reply_to_address).deliver_now!
      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.subject).to eql("Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}")
      expect(last_delivery.to).to include(enquiry.user.email)
      expect(last_delivery.bcc).to include(enquiry_response.editor.email)
      expect(last_delivery.reply_to).to include(reply_to_address)
      expect(last_delivery.parts.first.body.raw_source).to include('Your proposal will not be taken any further')
    end

    it 'sends an enquiry response to the person creating the enquiry and the editor responding to it with response type 4 (not uk registered)' do
      enquiry = create(:enquiry)
      enquiry_response = create(:enquiry_response, enquiry: enquiry, response_type: 4)
      reply_to_address = 'noreply@noreply.net'

      EnquiryResponseMailer.not_uk_registered(enquiry_response, enquiry_response.editor.email, reply_to_address).deliver_now!
      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.subject).to eql("Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}")
      expect(last_delivery.to).to include(enquiry.user.email)
      expect(last_delivery.bcc).to include(enquiry_response.editor.email)
      expect(last_delivery.reply_to).to include(reply_to_address)
      expect(last_delivery.parts.first.body.raw_source).to include('Your company is not UK registered.')
      expect(last_delivery.parts.first.body.raw_source).to include('include your company details')
    end

    it 'sends an enquiry response to the person creating the enquiry and the editor responding to it with response type 5 (not for third party)' do
      enquiry = create(:enquiry)
      enquiry_response = create(:enquiry_response, enquiry: enquiry, response_type: 5)
      reply_to_address = 'noreply@noreply.net'

      EnquiryResponseMailer.not_for_third_party(enquiry_response, enquiry_response.editor.email, reply_to_address).deliver_now!
      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.subject).to eql("Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}")
      expect(last_delivery.to).to include(enquiry.user.email)
      expect(last_delivery.bcc).to include(enquiry_response.editor.email)
      expect(last_delivery.reply_to).to include(reply_to_address)
      expect(last_delivery.parts.first.body.raw_source).to include('You are a third party - for example an agent, broker or other')
    end
  end
end
