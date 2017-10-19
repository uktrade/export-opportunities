require 'rails_helper'
require 'capybara/email/rspec'

RSpec.describe EnquiryResponseMailer, type: :mailer do
  describe '.send_enquiry_response without attachment' do
    it 'sends an enquiry response to the person creating the enquiry and the editor responding to it with response type 1 (right for opportunity)' do
      enquiry = create(:enquiry)
      enquiry_response = create(:enquiry_response, enquiry: enquiry, response_type: 1)

      EnquiryResponseMailer.right_for_opportunity(enquiry_response, enquiry_response.editor.email).deliver_later!

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

      EnquiryResponseMailer.not_right_for_opportunity(enquiry_response, enquiry_response.editor.email, reply_to_address).deliver_later!
      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.subject).to eql("Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}")
      expect(last_delivery.to).to include(enquiry.user.email)
      expect(last_delivery.bcc).to include(enquiry_response.editor.email)
      expect(last_delivery.reply_to).to include(reply_to_address)
      expect(last_delivery.parts.first.body.raw_source).to include('Your proposal will not be taken any further')
      expect(last_delivery.parts.first.body.raw_source).to include('Your proposal does not meet the criteria for this opportunity')
    end

    it 'sends an enquiry response to the person creating the enquiry and the editor responding to it with response type 4 (not uk registered)' do
      enquiry = create(:enquiry)
      enquiry_response = create(:enquiry_response, enquiry: enquiry, response_type: 4)
      reply_to_address = 'noreply@noreply.net'

      EnquiryResponseMailer.not_uk_registered(enquiry_response, enquiry_response.editor.email, reply_to_address).deliver_later!
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

      EnquiryResponseMailer.not_for_third_party(enquiry_response, enquiry_response.editor.email, reply_to_address).deliver_later!
      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.subject).to eql("Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}")
      expect(last_delivery.to).to include(enquiry.user.email)
      expect(last_delivery.bcc).to include(enquiry_response.editor.email)
      expect(last_delivery.reply_to).to include(reply_to_address)
      expect(last_delivery.parts.first.body.raw_source).to include('You are a third party - for example an agent, broker or other')
      expect(last_delivery.parts.first.body.raw_source).to include('intermediary - representing another company. On this occasion the buyer')
    end
  end
end
