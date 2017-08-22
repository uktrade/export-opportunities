require 'rails_helper'
require 'capybara/email/rspec'

RSpec.describe EnquiryResponseMailer, type: :mailer do
  describe '.send_enquiry_response' do
    it 'sends an enquiry response to the person creating the enquiry and the editor responding to it with response type 1 (right for opportunity)' do

      enquiry = create(:enquiry)
      enquiry_response = create(:enquiry_response, enquiry: enquiry, response_type: 1)
      EnquiryResponseMailer.right_for_opportunity(enquiry_response, enquiry, 'noreply@noreply.net').deliver_later!
      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.attachments.first.filename).to include('tender_sample_file.txt')
      expect(last_delivery.subject).to eql("Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}")
      expect(last_delivery.to).to include(enquiry.user.email)
      expect(last_delivery.bcc).to include(enquiry_response.editor.email)
      expect(last_delivery.reply_to).to include(enquiry_response.editor.email)
    end
  end

  describe '.send_enquiry_response' do
    it 'sends an enquiry response to the person creating the enquiry and the editor responding to it with response type 2 (needs more information)' do
      skip
      enquiry = create(:enquiry)
      enquiry_response = create(:enquiry_response, enquiry: enquiry, response_type: 2)
      EnquiryResponseMailer.more_information(enquiry_response, enquiry, 'editor@great.gov.uk').deliver_later!
      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.attachments.first.filename).to include('tender_sample_file.txt')
      expect(last_delivery.subject).to eql("Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}")
      expect(last_delivery.to).to include(enquiry.user.email)
      expect(last_delivery.bcc).to include(enquiry_response.editor.email)
      expect(last_delivery.reply_to).to include(enquiry_response.editor.email)
    end
  end

  describe '.send_enquiry_response' do
    it 'sends an enquiry response to the person creating the enquiry and the editor responding to it with response type 3 (NOT right for opportunity)' do

      enquiry = create(:enquiry)
      enquiry_response = create(:enquiry_response, enquiry: enquiry, response_type: 3)
      EnquiryResponseMailer.not_right_for_opportunity(enquiry_response, enquiry, 'noreply@noreply.net').deliver_later!
      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.attachments.first.filename).to include('tender_sample_file.txt')
      expect(last_delivery.subject).to eql("Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}")
      expect(last_delivery.to).to include(enquiry.user.email)
      expect(last_delivery.bcc).to include(enquiry_response.editor.email)
      expect(last_delivery.reply_to).to include(enquiry_response.editor.email)
    end
  end

  describe '.send_enquiry_response' do
    it 'sends an enquiry response to the person creating the enquiry and the editor responding to it with response type 4 (not uk registered)' do
      skip
      enquiry = create(:enquiry)
      enquiry_response = create(:enquiry_response, enquiry: enquiry, response_type: 4)
      EnquiryResponseMailer.not_uk_registered(enquiry_response, enquiry, 'noreply@noreply.net').deliver_later!
      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.attachments.first.filename).to include('tender_sample_file.txt')
      expect(last_delivery.subject).to eql("Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}")
      expect(last_delivery.to).to include(enquiry.user.email)
      expect(last_delivery.bcc).to include(enquiry_response.editor.email)
      expect(last_delivery.reply_to).to include(enquiry_response.editor.email)
    end
  end

  describe '.send_enquiry_response' do
    it 'sends an enquiry response to the person creating the enquiry and the editor responding to it with response type 5 (not for third party)' do
      skip
      enquiry = create(:enquiry)
      enquiry_response = create(:enquiry_response, enquiry: enquiry, response_type: 5)
      EnquiryResponseMailer.right_for_opportunity(enquiry_response, enquiry, 'noreply@noreply.net').deliver_later!
      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.attachments.first.filename).to include('tender_sample_file.txt')
      expect(last_delivery.subject).to eql("Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}")
      expect(last_delivery.to).to include(enquiry.user.email)
      expect(last_delivery.bcc).to include(enquiry_response.editor.email)
      expect(last_delivery.reply_to).to include(enquiry_response.editor.email)
    end
  end
end
