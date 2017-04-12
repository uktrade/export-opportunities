class EnquiryFeedbackSender
  def call(enquiry)
    raise UserOptedOut if FeedbackOptOut.exists?(user: enquiry.user)

    enquiry_feedback = enquiry.create_feedback!
    EnquiryFeedbackMailer.request_feedback(enquiry_feedback).deliver_later!
  end

  class UserOptedOut < StandardError; end
end
