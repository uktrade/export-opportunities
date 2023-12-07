require 'rails_helper'
require 'capybara/email/rspec'

RSpec.describe EnquiryMailer, type: :mailer do
  describe '.send_enquiry' do
    it 'sends an enquiry to its contacts' do
      enquiry = create(:enquiry)
      EnquiryMailer.send_enquiry(enquiry).deliver_now!
      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.subject).to eql("Enquiry from #{enquiry.company_name}: action required within 5 working days")
      expect(last_delivery.to).to eql(enquiry.opportunity.contacts.pluck(:email))
      expect(last_delivery.to_s).to include(enquiry.opportunity.title)
      expect(last_delivery.to_s).to include(enquiry.company_name)
    end

    it 'sends an enquiry to a PTU exempted service provider' do
      excepted_service_provider_id = Figaro.env.PTU_EXEMPT_SERVICE_PROVIDERS
      service_provider = create(:service_provider, id: excepted_service_provider_id.split(',').first)
      author = create(:editor, service_provider: service_provider)
      opportunity = create(:opportunity, author: author)
      enquiry = create(:enquiry, opportunity: opportunity)

      EnquiryMailer.send_enquiry(enquiry).deliver_now!
      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.subject).to eql("Enquiry from #{enquiry.company_name}: action required within 5 working days")
      expect(last_delivery.to).to eql(enquiry.opportunity.contacts.pluck(:email))
      expect(last_delivery.to_s).to include(enquiry.company_name)
    end

    it 'sends an enquiry to a mandatory PTU service provider', skip: true do
      # pick a service provider id that will not get exempted from mandatory PTU
      service_provider = create(:service_provider, id: 101)
      author = create(:editor, service_provider: service_provider)
      opportunity = create(:opportunity, author: author)
      enquiry = create(:enquiry, opportunity: opportunity)

      EnquiryMailer.send_enquiry(enquiry).deliver_now!
      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.subject).to eql("Enquiry from #{enquiry.company_name}: action required within 5 working days")
      expect(last_delivery.to).to eql(enquiry.opportunity.contacts.pluck(:email))
      expect(last_delivery.to_s).to include('You need to respond to the enquiry using the correct reply template in the admin centre by')
      expect(last_delivery.to_s).to include(enquiry.company_name)
    end

    it 'CCs if set' do
      allow(Figaro.env).to receive(:enquiries_cc_email).and_return('dit-cc@example.org')

      enquiry = create(:enquiry)
      EnquiryMailer.send_enquiry(enquiry).deliver_now!
      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.cc).to eql(['dit-cc@example.org'])
    end

    it 'does not CC if not set' do
      allow(Figaro.env).to receive(:enquiries_cc_email)

      enquiry = create(:enquiry)
      EnquiryMailer.send_enquiry(enquiry).deliver_now!
      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.cc).to eql(nil)
    end

    it 'does not CC if nil' do
      allow(Figaro.env).to receive(:enquiries_cc_email).and_return(nil)

      enquiry = create(:enquiry)
      EnquiryMailer.send_enquiry(enquiry).deliver_now!
      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.cc).to eql(nil)
    end
  end
end
