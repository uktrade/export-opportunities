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
      # expect(last_delivery.to).to eql(enquiry.opportunity.contacts.pluck(:email))
      # expect(last_delivery.to_s).to include(enquiry.opportunity.title)
      # expect(last_delivery.to_s).to include(enquiry.company_name)
    end

    # it 'CCs if set' do
    #   allow(Figaro.env).to receive(:enquiries_cc_email).and_return('dit-cc@example.org')
    #
    #   enquiry = create(:enquiry)
    #   EnquiryMailer.send_enquiry(enquiry).deliver_later!
    #   last_delivery = ActionMailer::Base.deliveries.last
    #
    #   expect(last_delivery.cc).to eql(['dit-cc@example.org'])
    # end
    #
    # it 'does not CC if not set' do
    #   allow(Figaro.env).to receive(:enquiries_cc_email)
    #
    #   enquiry = create(:enquiry)
    #   EnquiryMailer.send_enquiry(enquiry).deliver_later!
    #   last_delivery = ActionMailer::Base.deliveries.last
    #
    #   expect(last_delivery.cc).to eql(nil)
    # end
    #
    # it 'does not CC if nil' do
    #   allow(Figaro.env).to receive(:enquiries_cc_email).and_return(nil)
    #
    #   enquiry = create(:enquiry)
    #   EnquiryMailer.send_enquiry(enquiry).deliver_later!
    #   last_delivery = ActionMailer::Base.deliveries.last
    #
    #   expect(last_delivery.cc).to eql(nil)
    # end
  end
end
