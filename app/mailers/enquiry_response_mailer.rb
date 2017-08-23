class EnquiryResponseMailer < ApplicationMailer
  layout 'eig-email'

  def right_for_opportunity(enquiry_response, editor_email, reply_to_address)
    @enquiry_response = enquiry_response
    mail from: editor_email.to_s, name: 'Export opportunities', reply_to: reply_to_address, sender: 'noreply@export.great.gov.uk', to: enquiry_response.enquiry.user.email, bcc: editor_email, subject: "Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}"
  end

  def more_information(enquiry_response, editor_email, reply_to_address)
    @enquiry_response = enquiry_response
    mail from: editor_email.to_s, name: 'Export opportunities', reply_to: reply_to_address, sender: 'noreply@export.great.gov.uk', to: enquiry_response.enquiry.user.email, bcc: editor_email, subject: "Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}"
  end
  def not_right_for_opportunity(enquiry_response, editor_email, reply_to_address)
    @enquiry_response = enquiry_response
    mail from: editor_email.to_s, name: 'Export opportunities', reply_to: reply_to_address, sender: 'noreply@export.great.gov.uk', to: enquiry_response.enquiry.user.email, bcc: editor_email, subject: "Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}"
  end

  def not_uk_registered(enquiry_response, editor_email, reply_to_address)
    @enquiry_response = enquiry_response
    mail from: editor_email.to_s, name: 'Export opportunities', reply_to: reply_to_address, sender: 'noreply@export.great.gov.uk', to: enquiry_response.enquiry.user.email, bcc: editor_email, subject: "Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}"
  end

  def not_for_third_party(enquiry_response, editor_email, reply_to_address)
    @enquiry_response = enquiry_response
    mail from: editor_email.to_s, name: 'Export opportunities', reply_to: reply_to_address, sender: 'noreply@export.great.gov.uk', to: enquiry_response.enquiry.user.email, bcc: editor_email, subject: "Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}"
  end

end
