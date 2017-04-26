class EnquiryFeedbackMailer < ApplicationMailer
  layout 'eig-email'
  def request_feedback(enquiry_feedback)
    @enquiry_feedback = enquiry_feedback

    mail(to: @enquiry_feedback.enquiry.email, subject: 'What happened with your export opportunity #{@enquiry_feedback.enquiry.opportunity.title}?')
  end
end
