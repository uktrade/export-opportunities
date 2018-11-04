class EnquiryFeedbackMailer < ApplicationMailer
  def request_feedback(enquiry_feedback)
    @content = get_content('enquiry_feedback.yml')
    @enquiry_feedback = enquiry_feedback

    mail(from: Figaro.env.MAILER_FROM_ADDRESS!, name: 'Export opportunities', to: @enquiry_feedback.enquiry.email, subject: "Give feedback on \"#{@enquiry_feedback.enquiry.opportunity.title}\"?")
  end
end
