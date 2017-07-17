class EnquiryFeedbackSender
  def call(enquiry)
    enquiry = Enquiry.find(enquiry) unless enquiry.is_a?(Enquiry)
    raise UserOptedOut if FeedbackOptOut.exists?(user: enquiry.user)

    unless EnquiryFeedback.where(enquiry_id: enquiry.id).exists?
      enquiry_feedback = enquiry.create_feedback!
      EnquiryFeedbackMailer.request_feedback(enquiry_feedback).deliver_later!
    end
  end
  class UserOptedOut < StandardError; end
end
