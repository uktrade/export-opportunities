class EnquiryResponseMailer < ApplicationMailer
  include ContentHelper

  layout 'eig-email'

  def right_for_opportunity(enquiry_response, editor_email)
    @mailer_view = true
    @enquiry_response = enquiry_response
    mail from: Figaro.env.MAILER_FROM_ADDRESS!, name: 'Export opportunities', reply_to: editor_email, to: enquiry_response.enquiry.user.email, bcc: editor_email, subject: "Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}"
  end

  def more_information(enquiry_response, editor_email)
    @mailer_view = true
    @enquiry_response = enquiry_response
    mail from: Figaro.env.MAILER_FROM_ADDRESS!, name: 'Export opportunities', reply_to: editor_email, to: enquiry_response.enquiry.user.email, bcc: editor_email, subject: "Update on your enquiry for the export opportunity #{enquiry_response.enquiry.opportunity.title}"
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

  def reminder(enquiry)
    return if enquiry.opportunity.contacts.blank?

    @mailer_view = true

    @opportunity = enquiry.opportunity
    @enquiry = enquiry
    @content = get_content('emails/response_reminder_mailer.yml')['reminder']
    enquiry.update(response_reminder_sent_at: Time.zone.now)

    mail(to: @opportunity.contacts.pluck(:email),
         from: Figaro.env.MAILER_FROM_ADDRESS!,
         name: 'Export opportunities',
         reply_to: Figaro.env.CONTACT_US_EMAIL,
         subject: "#{_content 'title_prefix'} #{_content('title_main')}") do |format|
      format.html { render(layout: 'email') }
      format.text
    end
  end
end
