class EnquiryFeedbackMailer < ApplicationMailer
  layout 'eig-email'
  def request_feedback(enquiry_feedback)
    @enquiry_feedback = enquiry_feedback

    mail(from: 'Export opportunities', to: @enquiry_feedback.enquiry.email, subject: 'Help us improve the Export Opportunities service')
  end
end
