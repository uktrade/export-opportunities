class EnquiryMailer < ApplicationMailer
  include Devise::Mailers::Helpers

  def send_enquiry(enquiry)
    @enquiry = enquiry
    return if @enquiry.opportunity.contacts.nil?

    email_addresses = @enquiry.opportunity.contacts.pluck(:email)

    subject = "Enquiry from #{@enquiry.company_name}: action required within 5 working days"

    args = if service_provider_exception(enquiry)
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

  # Sends a reminder email to the opportunity contacts (Post)
  # when they do not respond the an enquiry in expected time.
  def reminder(enquiry, number, content)
    if enquiry.opportunity.contacts.present? && !service_provider_exception(enquiry)

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

      @content = content
      @enquiry = enquiry
      @opportunity = enquiry.opportunity
      @reminder_number = reminder_number

      mail(args)
    end
  end

  def reminders(enquiry_reminders)
    content = get_content('opportunities/show.yml')
    enquiry_reminders.each do |reminder|
      reminder(reminder[:enquiry], reminder[:number], content)
    end
  end

  private def service_provider_exception(enquiry)
    service_provider_id = enquiry.opportunity.service_provider.id
    excepted_service_providers = Figaro.env.PTU_EXEMPT_SERVICE_PROVIDERS!
    excepted_service_providers.split(',').map(&:to_i).include? service_provider_id
  end
end
