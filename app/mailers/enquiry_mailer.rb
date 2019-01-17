class EnquiryMailer < ApplicationMailer
  include Devise::Mailers::Helpers
  include ContentHelper

  def send_enquiry(enquiry)
    @enquiry = enquiry
    return if @enquiry.opportunity.contacts.nil?

    email_addresses = @enquiry.opportunity.contacts.pluck(:email)

    subject = "Enquiry from #{@enquiry.company_name}: action required within 5 working days"

    args = if service_provider_exception(enquiry)
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

    if Figaro.env.enquiries_cc_email.present?
      args[:cc] = Figaro.env.enquiries_cc_email
    end

    mail(args)
  end

  private def service_provider_exception(enquiry)
    service_provider_id = enquiry.opportunity.service_provider.id
    excepted_service_providers = Figaro.env.PTU_EXEMPT_SERVICE_PROVIDERS!
    excepted_service_providers.split(',').map(&:to_i).include? service_provider_id
  end
end
