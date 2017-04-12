class EnquiryFeedbackSurveySender
  def call(start_date:, end_date:, sample_size:)
    enquiries_in_range = Enquiry.where(created_at: start_date..end_date).ids

    enquiries_with_existing_feedback = EnquiryFeedback.pluck(:enquiry_id)
    enquiries_on_email_blacklist = Enquiry.where(user_id: FeedbackOptOut.pluck(:user_id)).ids

    candidates = enquiries_in_range -
                 enquiries_with_existing_feedback -
                 enquiries_on_email_blacklist

    # Select each user only once
    records = Enquiry.where(id: candidates).order('RANDOM()').to_a.uniq(&:user_id)

    feedback_sender = EnquiryFeedbackSender.new

    records.sample(sample_size).each do |enquiry|
      feedback_sender.call(enquiry)
    end
  end
end
