class EnquiryFeedbackSurveySender
  def call
    end_date = Time.zone.now.beginning_of_day
    start_date = end_date - 1.day

    enquiries_in_range = Enquiry.where(created_at: start_date..end_date).ids

    enquiries_on_email_blacklist = Enquiry.where(user_id: FeedbackOptOut.pluck(:user_id)).ids

    candidates = enquiries_in_range - enquiries_on_email_blacklist

    feedback_sender = EnquiryFeedbackSender.new

    candidates.each do |enquiry|
      feedback_sender.call(enquiry)
    end
  end
end
