require 'rails_helper'

RSpec.describe EnquiryFeedbackSender do
  describe '#call' do
    it 'creates a new EnquiryFeedback record' do
      enquiry = create(:enquiry)
      sender = EnquiryFeedbackSender.new

      sender.call(enquiry)

      expect(enquiry.feedback).to be_present
    end

    it 'sends an email', skip: true do
      enquiry = create(:enquiry)
      sender = EnquiryFeedbackSender.new

      expect { sender.call(enquiry) }.to change { ActionMailer::Base.deliveries.size }.by(1)
    end

    it 'will not send an email to an opted-out address' do
      user = create(:user, email: 'i-have-opted-out@no-more-email.com')
      create(:feedback_opt_out, user: user)
      enquiry = create(:enquiry, user: user)
      sender = EnquiryFeedbackSender.new

      expect { sender.call(enquiry.id) }.to raise_error(EnquiryFeedbackSender::UserOptedOut)
    end
  end
end
