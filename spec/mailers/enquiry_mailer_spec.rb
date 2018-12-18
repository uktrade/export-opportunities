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

    it 'sends an enquiry to a mandatory PTU service provider' do
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

  describe '.reminder' do
    let(:view_context) { ActionController::Base.helpers }

    it 'sends a reminder email to contacts' do
      tch = TestContentHelper.new
      content = tch.get_content('emails/enquiry_mailer.yml')
      enquiry = create(:enquiry)
      EnquiryMailer.reminder(enquiry, 1, content['reminder']).deliver_now!
      last_delivery = ActionMailer::Base.deliveries.last
      subject = "#{tch.content_with_inclusion('reminder.title_prefix', ['First'])} #{tch.content('reminder.title_main')}"
      expect(last_delivery.subject).to eql(subject)
      expect(last_delivery.to).to eql(enquiry.opportunity.contacts.pluck(:email))
      expect(last_delivery.from).to eql([Figaro.env.MAILER_FROM_ADDRESS])
      expect(last_delivery.to_s).to include(enquiry.opportunity.title)
      expect(last_delivery.to_s).to include(enquiry.company_name)
    end
  end

  describe '.reminders' do

    it 'sends a reminder email for each' do
      tch = TestContentHelper.new
      content = tch.get_content('emails/enquiry_mailer.yml')
      enquiry1 = create(:enquiry)
      enquiry2 = create(:enquiry)
      enquiry_reminders = [{ enquiry: enquiry1, number: 1 }, { enquiry: enquiry2, number: 3 }]
      EnquiryMailer.reminders(enquiry_reminders).deliver_now!
      last_delivery = ActionMailer::Base.deliveries.last
      subject = "#{tch.content_with_inclusion('reminder.title_prefix', ['Third'])} #{tch.content('reminder.title_main')}"

      expect(last_delivery.subject).to eql(subject)
      expect(last_delivery.to).to eql(enquiry2.opportunity.contacts.pluck(:email))
      expect(last_delivery.from).to eql([Figaro.env.MAILER_FROM_ADDRESS])
      expect(last_delivery.to_s).to include(enquiry2.opportunity.title)
      expect(last_delivery.to_s).to include(enquiry2.company_name)
    end
  end

  class TestContentHelper
    include ContentHelper
  end
end
