require 'rails_helper'

RSpec.describe EnquiryResponseSender do
  describe '#call' do
    it 'creates a new EnquiryResponse record' do
      enquiry = create(:enquiry)
      enquiry_response = create(:enquiry_response, enquiry: enquiry)
      sender = EnquiryResponseSender.new

      sender.call(enquiry_response, enquiry)

      expect { sender.call(enquiry_response, enquiry) }.to change { ActionMailer::Base.deliveries.size }.by(1)
    end
  end
end
