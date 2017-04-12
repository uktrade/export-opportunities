class EnquiryMailer < ApplicationMailer
  include Devise::Mailers::Helpers

  def send_enquiry(enquiry)
    @enquiry = enquiry
    return if @enquiry.opportunity.contacts.nil?

    email_addresses = @enquiry.opportunity.contacts.pluck(:email)

    args = {
      to: email_addresses,
      subject: "EIG Website : Export opportunity : Action required : Customer : #{@enquiry.first_name} #{@enquiry.last_name}",
    }

    if Figaro.env.enquiries_cc_email.present?
      args[:cc] = Figaro.env.enquiries_cc_email
    end

    mail(args)
  end
end
