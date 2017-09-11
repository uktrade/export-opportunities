require 'notifications/client'

class EnquiryResponseMailer < ApplicationMailer
  layout 'eig-email'

  def right_for_opportunity(enquiry_response, editor_email)
    @mailer_view = true
    @enquiry_response = enquiry_response
    client = Notifications::Client.new(Figaro.env.gov_notify_api_key!)

    enquiry_user_email = Figaro.env.gov_notify_default_send_to! || enquiry_response.enquiry.user.email
    response = client.send_email(
      email_address:  enquiry_user_email,
      template_id: Figaro.env.gov_notify_enquiry_response_win_template!,
      personalisation: {
        opp_title: enquiry_response.enquiry.opportunity.title,
        ukbusiness_name: enquiry_response.enquiry.first_name,
        post_text_body: enquiry_response.email_body,
        post_document_url: enquiry_response.documents,
        post_signature: enquiry_response.signature,
      },
      reference: "exopps_reference_string"
    )
    pp response
    mail from: editor_email.to_s, name: 'Export opportunities', reply_to: editor_email, sender: 'noreply@export.great.gov.uk', to: enquiry_response.enquiry.user.email, bcc: editor_email, subject: "Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}"
  end

  def more_information(enquiry_response, editor_email)
    @mailer_view = true
    @enquiry_response = enquiry_response
    mail from: editor_email.to_s, name: 'Export opportunities', reply_to: editor_email, sender: 'noreply@export.great.gov.uk', to: enquiry_response.enquiry.user.email, bcc: editor_email, subject: "Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}"
  end

  def not_right_for_opportunity(enquiry_response, editor_email, reply_to_address)
    @mailer_view = true
    @enquiry_response = enquiry_response
    mail from: editor_email.to_s, name: 'Export opportunities', reply_to: reply_to_address, sender: 'noreply@export.great.gov.uk', to: enquiry_response.enquiry.user.email, bcc: editor_email, subject: "Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}"
  end

  def not_uk_registered(enquiry_response, editor_email, reply_to_address)
    @mailer_view = true
    @enquiry_response = enquiry_response
    mail from: editor_email.to_s, name: 'Export opportunities', reply_to: reply_to_address, sender: 'noreply@export.great.gov.uk', to: enquiry_response.enquiry.user.email, bcc: editor_email, subject: "Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}"
  end

  def not_for_third_party(enquiry_response, editor_email, reply_to_address)
    @mailer_view = true
    @enquiry_response = enquiry_response
    mail from: editor_email.to_s, name: 'Export opportunities', reply_to: reply_to_address, sender: 'noreply@export.great.gov.uk', to: enquiry_response.enquiry.user.email, bcc: editor_email, subject: "Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}"
  end
end
