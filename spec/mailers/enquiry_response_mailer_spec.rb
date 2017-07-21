require 'rails_helper'
require 'capybara/email/rspec'

RSpec.describe EnquiryResponseMailer, type: :mailer do
  describe '.send_enquiry_response' do
    it 'sends an enquiry response to the person creating the enquiry and the editor responding to it' do
      enquiry = create(:enquiry)
      enquiry_response = create(:enquiry_response, enquiry: enquiry)
      EnquiryResponseMailer.send_enquiry_response(enquiry_response, enquiry).deliver_later!
      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.subject).to eql("Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}")
      expect(last_delivery.to).to include(enquiry.user.email)
      expect(last_delivery.bcc).to include(enquiry_response.editor.email)
      expect(last_delivery.reply_to).to include(enquiry_response.editor.email)
    end
  end
end
