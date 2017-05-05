class EnquiryFeedbackMailer < ApplicationMailer
  layout 'eig-email'
  def request_feedback(enquiry_feedback)
    @enquiry_feedback = enquiry_feedback

    mail(from: 'Export opportunities', to: @enquiry_feedback.enquiry.email, subject: 'Give feedback on #{@enquiry_feedback.enquiry.opportunity.title}?')
  end
end
