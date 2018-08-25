class EnquiryFeedbackMailer < ApplicationMailer
  layout 'eig-email-survey'
  def request_feedback(enquiry_feedback)
    @enquiry_feedback = enquiry_feedback

    mail(from: ENV.fetch('MAILER_FROM_ADDRESS'), name: 'Export opportunities', to: @enquiry_feedback.enquiry.email, subject: "Give feedback on \"#{@enquiry_feedback.enquiry.opportunity.title}\"?")
  end
end
