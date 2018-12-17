class EnquiryMailer < ApplicationMailer
  include Devise::Mailers::Helpers

  def send_enquiry(enquiry)
    @enquiry = enquiry
    return if @enquiry.opportunity.contacts.nil?

    excepted_service_providers = Figaro.env.PTU_EXEMPT_SERVICE_PROVIDERS!

    email_addresses = @enquiry.opportunity.contacts.pluck(:email)

    subject = "Enquiry from #{@enquiry.company_name}: action required within 5 working days"

    args = if excepted_service_providers.split(',').map(&:to_i).include? @enquiry.opportunity.service_provider.id
             {
               template_name: 'sendenquiry_seller_details',
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

  def reminder(enquiry, number)
    if enquiry.opportunity.contacts.present?

      # Convert number to required output format
      reminder = %w[Last first second third fourth fifth sixth seventh eigth ninth tenth]
      reminder_number = number < reminder.length ? reminder[number].capitalize : "#{number}th"

      args = {
               template_name: 'reminder',
               to: enquiry.opportunity.contacts.pluck(:email),
               subject: "#{reminder_number} reminder: respond to enquiry",
             }

      if Figaro.env.enquiries_cc_email.present?
        args[:cc] = Figaro.env.enquiries_cc_email
      end

      @content = get_content('opportunities/show.yml')
      @enquiry = enquiry
      @opportunity = enquiry.opportunity
      @reminder_number = reminder_number

      mail(args)
    end
  end
end
