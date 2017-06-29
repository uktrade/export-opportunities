class EnquiryResponseMailer < ApplicationMailer
  layout 'eig-email'

  def send_enquiry_response(enquiry_response, enquiry)
    @enquiry_response = enquiry_response
    @enquiry = enquiry
    editor_email = @enquiry_response.editor.email

    attachments[enquiry_response.email_attachment_file_name] = File.read(enquiry_response.email_attachment.path) if enquiry_response.email_attachment_file_name
    mail from: editor_email.to_s, name: 'Export opportunities', reply_to: editor_email.to_s, sender: 'noreply@export.great.gov.uk', to: @enquiry.user.email, bcc: editor_email, subject: "Update on your enquiry for the export opportunity #{@enquiry.opportunity.title}"
  end
end
