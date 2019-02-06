class EnquiryMailer < ApplicationMailer
  include Devise::Mailers::Helpers
  include ContentHelper

  def send_enquiry(enquiry)
    @enquiry = enquiry
    return if @enquiry.opportunity.contacts.nil?

    email_addresses = @enquiry.opportunity.contacts.pluck(:email)

    subject = "Enquiry from #{@enquiry.company_name}: action required within 5 working days"

    args = {
      to: email_addresses,
      subject: subject,
    }

    args[:template_name] = if service_provider_exception(enquiry)
                             'send_enquiry_seller_details'
                           else
                             'send_enquiry'
                           end

    if Figaro.env.enquiries_cc_email.present?
      args[:cc] = Figaro.env.enquiries_cc_email
    end

    mail(args)
  end

  private

    def service_provider_exception(enquiry)
      service_provider_id = enquiry.opportunity.service_provider.id
      excepted_service_providers = Figaro.env.PTU_EXEMPT_SERVICE_PROVIDERS!
      excepted_service_providers.split(',').map(&:to_i).include? service_provider_id
    end
end
