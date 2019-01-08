class ResponseReminderMailer < ApplicationMailer
  include ContentHelper
  # layout 'email'

  # Day 7
  def reminder(enquiry)
    return if enquiry.opportunity.contacts.blank? # TEST
    @mailer_view = true

    @opportunity = enquiry.opportunity
    @enquiry = enquiry
    @content = get_content('emails/response_reminder_mailer.yml')['reminder']
    enquiry.update(response_reminder_sent_at: DateTime.now)

    mail to: @opportunity.contacts.pluck(:email), #TEST
         from: Figaro.env.MAILER_FROM_ADDRESS!,
         name: 'Export opportunities',
         reply_to: Figaro.env.CONTACT_US_EMAIL,
         subject: "#{content 'title_prefix'} #{content('title_main')}"
  end
end

# Not yet used but likely in time, so leaving here [8 Jan 2019]
# Day 14
# def second_reminder(enquiry)
#   @mailer_view = true
  
#   @opportunity = enquiry.opportunity
#   @opportunity_country_title = opportunity_country_title
#   @enquiry_company_name = enquiry.company_name
#   @response_deadline = (enquiry.created_at + 28.days).strftime("%A %-d %B")
#   @enquiry = enquiry
#   @author = @opportunity.author
  
#   enquiry.update(response_second_reminder_sent_at: DateTime.now)
#   mail to: @author.email,
#        from: Figaro.env.MAILER_FROM_ADDRESS!,
#        name: 'Export opportunities',
#        reply_to: Figaro.env.CONTACT_US_EMAIL,
#        cc: Figaro.env.LATE_RESPONSE_SUPPORT_INBOX,
#        subject: "2nd reminder: respond to enquiry"
# end

# # Day 21
# def first_reminder_escalation(enquiry)
#   @mailer_view = true

#   @opportunity = enquiry.opportunity
#   @enquiry = enquiry
#   @author = @opportunity.author
#   @opportunity_country_title = opportunity_country_title
#   @deadline = (enquiry.created_at + 28.days).strftime("%A %-d %B")
#   @enquiry_company_name = enquiry.company_name
#   enquiry.update(response_first_reminder_escalation_sent_at: DateTime.now)

#   mail to: Figaro.env.LATE_RESPONSE_ESCALATION_INBOX,
#        from: Figaro.env.MAILER_FROM_ADDRESS!,
#        name: 'Export opportunities',
#        reply_to: Figaro.env.CONTACT_US_EMAIL,
#        cc: Figaro.env.LATE_RESPONSE_SUPPORT_INBOX,
#        subject: "Response 21 days overdue"
# end

# # Day 28
# def second_reminder_escalation(enquiry)
#   @mailer_view = true

#   @opportunity = enquiry.opportunity
#   @enquiry = enquiry
#   @author = @opportunity.author
#   @opportunity_country_title = opportunity_country_title
#   @enquiry_company_name = enquiry.company_name
#   enquiry.update(response_second_reminder_escalation_sent_at: DateTime.now)

#   mail to: Figaro.env.LATE_RESPONSE_ESCALATION_INBOX,
#        from: Figaro.env.MAILER_FROM_ADDRESS!,
#        name: 'Export opportunities',
#        reply_to: Figaro.env.CONTACT_US_EMAIL,
#        subject: "Response 28 days overdue"
# end
