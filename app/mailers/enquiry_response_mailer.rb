class EnquiryResponseMailer < ApplicationMailer
  layout 'eig-email'

  def send_enquiry_response(enquiry_response, enquiry, response_documents)
    @enquiry_response = enquiry_response
    @enquiry = enquiry
    editor_email = @enquiry_response.editor.email

    if response_documents.instance_of?(Array)
      response_documents.each do |attachment|
        attachments[attachment.email_attachment_file_name] = File.read(attachment.email_attachment.path)
      end
    else
      attachments[response_documents.email_attachment_file_name] = File.read(response_documents.email_attachment.path)
    end

    mail from: editor_email.to_s, name: 'Export opportunities', reply_to: editor_email.to_s, sender: 'noreply@export.great.gov.uk', to: @enquiry.user.email, bcc: editor_email, subject: "Update on your enquiry for the export opportunity #{@enquiry.opportunity.title}"
  end
end
