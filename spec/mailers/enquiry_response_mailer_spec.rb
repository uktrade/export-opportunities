require 'rails_helper'
require 'capybara/email/rspec'

RSpec.describe EnquiryResponseMailer, type: :mailer do
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

  describe '#reminder' do

    def mail
      ActionMailer::Base.deliveries.last
    end

    def count
      ActionMailer::Base.deliveries.count
    end

    before do
      @enquiry = create(:enquiry)
    end

    it 'sends reminder and updates response reminder sent_at date' do
      expect(@enquiry.opportunity.contacts.any?).to be_truthy
      expect do
        EnquiryResponseMailer.reminder(@enquiry).deliver_now!
      end.to change{ @enquiry.response_reminder_sent_at }

      expect(mail.to).to eq(@enquiry.opportunity.contacts.pluck(:email))
      expect(mail.subject).to eql("First reminder: Respond to enquiry")
      expect(mail.reply_to).to include(Figaro.env.CONTACT_US_EMAIL)
      expect(mail.parts.first.body.raw_source).to include('First reminder')
    end

    it 'does not send reminder if contacts are missing' do
      @enquiry.opportunity.contacts.destroy_all
      expect do
        EnquiryResponseMailer.reminder(@enquiry).deliver_now!
      end.to_not change{ count }
    end
  end
end

# Not yet used but likely in time, so leaving here [8 Jan 2019]
# it 'sends second_reminder' do
#   expect do
#     ResponseReminderMailer.second_reminder(@enquiry).deliver_now!
#   end.to change{ @enquiry.response_second_reminder_sent_at }

#   expect(mail.to).to include(@enquiry.opportunity.author.email)
#   expect(mail.subject).to eql("2nd reminder: respond to enquiry")
#   expect(mail.reply_to).to include(Figaro.env.CONTACT_US_EMAIL)
#   expect(mail.cc).to include(Figaro.env.LATE_RESPONSE_SUPPORT_INBOX)
#   expect(mail.parts.first.body.raw_source).to include('2nd reminder: respond to enquiry')
# end

# it 'sends first_reminder_escalation' do
#   expect do
#     ResponseReminderMailer.first_reminder_escalation(@enquiry).deliver_now!
#   end.to change{ @enquiry.response_first_reminder_escalation_sent_at }

#   expect(mail.to).to include(Figaro.env.LATE_RESPONSE_ESCALATION_INBOX)
#   expect(mail.subject).to eql("Response 21 days overdue")
#   expect(mail.parts.first.body.raw_source).to include('Response 21 days overdue')
# end

# it 'sends second_reminder_escalation' do
#   expect do
#     ResponseReminderMailer.second_reminder_escalation(@enquiry).deliver_now!
#   end.to change{ @enquiry.response_second_reminder_escalation_sent_at }

#   expect(mail.to).to include(Figaro.env.LATE_RESPONSE_ESCALATION_INBOX)
#   expect(mail.subject).to eql("Response 28 days overdue")
#   expect(mail.parts.first.body.raw_source).to include('Response 28 days overdue')
# end
