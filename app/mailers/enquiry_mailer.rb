class EnquiryMailer < ApplicationMailer
  include Devise::Mailers::Helpers

  def send_enquiry(enquiry)
    @enquiry = enquiry
    return if @enquiry.opportunity.contacts.nil?

    excepted_service_providers = ENV['PTU_EXEMPT_SERVICE_PROVIDERS']

    email_addresses = @enquiry.opportunity.contacts.pluck(:email)

    subject = "Enquiry from #{@enquiry.company_name}: action required within 5 working days"

    args = if excepted_service_providers.split(',').map(&:to_i).include? @enquiry.opportunity.service_provider.id
             {
               template_name: 'send_enquiry_seller_details',
               to: email_addresses,
               subject: subject,
             }
           else
             {
               template_name: 'send_enquiry',
               to: email_addresses,
               subject: subject,
             }
           end

    args[:cc] = ENV['ENQUIRIES_CC_EMAIL'] if ENV['ENQUIRIES_CC_EMAIL'].present?

    mail(args)
  end
end
