class EnquiryResponseLateMailer < ApplicationMailer
  layout 'eig-email'

  first_reminder
    to user
    subject "1st reminder: respond to enquiry"
    reply_to Figaro.env.export_opportunites_inbox (exportopportunities@) 'export_opportunites@inbox.com'
  second_reminder
    to user
    subject "2nd reminder: respond to enquiry"
    reply_to Figaro.env.export_opportunites_inbox (exportopportunities@) 'export_opportunites@inbox.com'
    cc  Figaro.env.late_response_support_inbox 'email@late_response_support.gov' 
  notify_internal_team_of_late_responder
    to Figaro.env.late_response_notifications_inbox 'email@late_response_notifications.gov'
    subject "Response 21 days overdue"
    reply_to Figaro.env.export_opportunites_inbox (exportopportunities@) 
  notify_internal_team_to_close_account_of_late_responder
    to Figaro.env.late_response_notifications_inbox 'email@late_response_notifications.gov'
    subject "Response 28 days overdue"
    reply_to Figaro.env.export_opportunites_inbox (exportopportunities@) 



  def right_for_opportunity(enquiry_response, editor_email)
    @mailer_view = true
    @enquiry_response = enquiry_response
    mail from: Figaro.env.MAILER_FROM_ADDRESS!,
         name: 'Export opportunities',
         reply_to: editor_email,
         to: enquiry_response.enquiry.user.email,
         bcc: editor_email,
         subject: "Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}"
  end

  def more_information(enquiry_response, editor_email)
    @mailer_view = true
    @enquiry_response = enquiry_response
    mail from: Figaro.env.MAILER_FROM_ADDRESS!,
         name: 'Export opportunities',
         reply_to: editor_email,
         to: enquiry_response.enquiry.user.email,
         bcc: editor_email,
         subject: "Update on your enquiry for the export opportunity\
                   #{enquiry_response.enquiry.opportunity.title}"
  end

  def not_right_for_opportunity(enquiry_response, editor_email, reply_to_address)
    @mailer_view = true
    @enquiry_response = enquiry_response
    mail from: reply_to_address,
         name: 'Export opportunities',
         reply_to: reply_to_address,
         to: enquiry_response.enquiry.user.email,
         bcc: editor_email,
         subject: "Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}"
  end

  def not_uk_registered(enquiry_response, editor_email, reply_to_address)
    @mailer_view = true
    @enquiry_response = enquiry_response
    mail from: reply_to_address,
         name: 'Export opportunities',
         reply_to: reply_to_address,
         to: enquiry_response.enquiry.user.email,
         bcc: editor_email,
         subject: "Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}"
  end

  def not_for_third_party(enquiry_response, editor_email, reply_to_address)
    @mailer_view = true
    @enquiry_response = enquiry_response
    mail from: reply_to_address,
         name: 'Export opportunities',
         reply_to: reply_to_address,
         to: enquiry_response.enquiry.user.email,
         bcc: editor_email,
         subject: "Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}"
  end
end
