class EnquiryResponseMailer < ApplicationMailer
  layout 'eig-email'

  def right_for_opportunity(enquiry_response, editor_email)
    @mailer_view = true
    @enquiry_response = enquiry_response
    mail from: ENV.fetch('MAILER_FROM_ADDRESS'), name: 'Export opportunities', reply_to: editor_email, to: enquiry_response.enquiry.user.email, bcc: editor_email, subject: "Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}"
  end

  def more_information(enquiry_response, editor_email)
    @mailer_view = true
    @enquiry_response = enquiry_response
    mail from: ENV.fetch('MAILER_FROM_ADDRESS'), name: 'Export opportunities', reply_to: editor_email, to: enquiry_response.enquiry.user.email, bcc: editor_email, subject: "Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}"
  end

  def not_right_for_opportunity(enquiry_response, editor_email, reply_to_address)
    @mailer_view = true
    @enquiry_response = enquiry_response
    mail from: reply_to_address, name: 'Export opportunities', reply_to: reply_to_address, to: enquiry_response.enquiry.user.email, bcc: editor_email, subject: "Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}"
  end

  def not_uk_registered(enquiry_response, editor_email, reply_to_address)
    @mailer_view = true
    @enquiry_response = enquiry_response
    mail from: reply_to_address, name: 'Export opportunities', reply_to: reply_to_address, to: enquiry_response.enquiry.user.email, bcc: editor_email, subject: "Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}"
  end

  def not_for_third_party(enquiry_response, editor_email, reply_to_address)
    @mailer_view = true
    @enquiry_response = enquiry_response
    mail from: reply_to_address, name: 'Export opportunities', reply_to: reply_to_address, to: enquiry_response.enquiry.user.email, bcc: editor_email, subject: "Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}"
  end
end
