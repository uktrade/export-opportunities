class EnquiryFeedbackSender
  def call(enquiry)
    enquiry = Enquiry.find(enquiry) unless enquiry.is_a?(Enquiry)
    raise UserOptedOut if FeedbackOptOut.exists?(user: enquiry.user)

    enquiry_feedback = enquiry.create_feedback! unless EnquiryFeedback.where(enquiry_id: enquiry.id).exists?
    EnquiryFeedbackMailer.request_feedback(enquiry_feedback).deliver_later!
  end

  class UserOptedOut < StandardError; end
end
