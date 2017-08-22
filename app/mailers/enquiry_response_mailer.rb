class EnquiryResponseMailer < ApplicationMailer
  layout 'eig-email'
  # layout 'enquiry_response_right_mailer/right_for_opportunity'

  def right_for_opportunity(enquiry_response, editor_email, reply_to_address)
    @enquiry_response = enquiry_response
    mail from: editor_email.to_s, name: 'Export opportunities', reply_to: reply_to_address, sender: 'noreply@export.great.gov.uk', to: enquiry_response.enquiry.user.email, bcc: editor_email, subject: "Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}"
  end

  def not_right_for_opportunity(enquiry_response, editor_email, reply_to_address)
    @enquiry_response = enquiry_response
    mail from: editor_email.to_s, name: 'Export opportunities', reply_to: reply_to_address, sender: 'noreply@export.great.gov.uk', to: enquiry_response.enquiry.user.email, bcc: editor_email, subject: "Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}"
  end

end
