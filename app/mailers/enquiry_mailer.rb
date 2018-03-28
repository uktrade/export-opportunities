class EnquiryMailer < ApplicationMailer
  include Devise::Mailers::Helpers

  def send_enquiry(enquiry)
    @enquiry = enquiry
    return if @enquiry.opportunity.contacts.nil?

    excepted_service_providers = Figaro.env.PTU_EXEMPT_SERVICE_PROVIDERS!

    email_addresses = @enquiry.opportunity.contacts.pluck(:email)

    args = if (excepted_service_providers.split(',').map(&:to_i).include? @enquiry.opportunity.service_provider.id)
             {
               template_name: 'send_enquiry_seller_details',
               to: email_addresses,
               subject: 'You’ve received an enquiry: Action required within 5 working days',
             }
           else
             {
               template_name: 'send_enquiry',
               to: email_addresses,
               subject: "Enquiry from #{@enquiry.company_name}: action required within 5 working days",
             }
           end

    if Figaro.env.enquiries_cc_email.present?
      args[:cc] = Figaro.env.enquiries_cc_email
    end

    mail(args)
  end
end
