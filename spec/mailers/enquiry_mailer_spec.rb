require 'rails_helper'
require 'capybara/email/rspec'

RSpec.describe OpportunityMailer, type: :mailer do
  describe '.send_enquiry' do
    it 'sends an enquiry to its contacts' do
      enquiry = create(:enquiry)
      EnquiryMailer.send_enquiry(enquiry).deliver_later!
      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.subject).to eql("EIG Website : Export opportunity : Action required : Customer : #{enquiry.first_name} #{enquiry.last_name}")
      expect(last_delivery.to).to eql(enquiry.opportunity.contacts.pluck(:email))
      expect(last_delivery.to_s).to include(enquiry.opportunity.title)
      expect(last_delivery.to_s).to include(enquiry.company_name)
    end

    it 'CCs if set' do
      allow(Figaro.env).to receive(:enquiries_cc_email).and_return('dit-cc@example.org')

      enquiry = create(:enquiry)
      EnquiryMailer.send_enquiry(enquiry).deliver_later!
      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.cc).to eql(['dit-cc@example.org'])
    end

    it 'does not CC if not set' do
      allow(Figaro.env).to receive(:enquiries_cc_email)

      enquiry = create(:enquiry)
      EnquiryMailer.send_enquiry(enquiry).deliver_later!
      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.cc).to eql(nil)
    end

    it 'does not CC if nil' do
      allow(Figaro.env).to receive(:enquiries_cc_email).and_return(nil)

      enquiry = create(:enquiry)
      EnquiryMailer.send_enquiry(enquiry).deliver_later!
      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.cc).to eql(nil)
    end
  end
end
