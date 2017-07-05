require 'rails_helper'
require 'capybara/email/rspec'

RSpec.describe EnquiryResponseMailer, type: :mailer do
  describe '.send_enquiry_response' do
    it 'sends an enquiry response to the person creating the enquiry and the editor responding to it' do
      enquiry = create(:enquiry)
      enquiry_response = create(:enquiry_response, enquiry: enquiry)
      response_document = create(:response_document, enquiry_response: enquiry_response)

      EnquiryResponseMailer.send_enquiry_response(enquiry_response, enquiry, response_document).deliver_later!
      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.attachments.first.filename).to include('tender_sample_file.txt')
      expect(last_delivery.subject).to eql("Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}")
      expect(last_delivery.to). to include(enquiry.user.email)
      expect(last_delivery.bcc). to include(enquiry_response.editor.email)
      expect(last_delivery.reply_to). to include(enquiry_response.editor.email)
    end

    it 'multiple attachments - sends an enquiry response to the person creating the enquiry and the editor responding to it' do
      enquiry = create(:enquiry)
      enquiry_response = create(:enquiry_response, enquiry: enquiry)
      response_document = create(:response_document, enquiry_response: enquiry_response)
      another_response_document = create(:response_document, enquiry_response: enquiry_response)

      EnquiryResponseMailer.send_enquiry_response(enquiry_response, enquiry, [response_document, another_response_document]).deliver_later!
      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.attachments.first.filename).to include('tender_sample_file.txt')
      expect(last_delivery.subject).to eql("Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}")
      expect(last_delivery.to). to include(enquiry.user.email)
      expect(last_delivery.bcc). to include(enquiry_response.editor.email)
      expect(last_delivery.reply_to). to include(enquiry_response.editor.email)
    end
  end
end
