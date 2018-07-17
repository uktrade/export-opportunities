class EnquiryFeedbackSurveySender
  def call(start_date = Time.zone.now.beginning_of_day - 3.months - 1.day, end_date = Time.zone.now.beginning_of_day - 3.months)
    opportunities_in_range = Opportunity.where(response_due_on: start_date..end_date)
    enquiries_in_range = Enquiry.where(opportunity_id: opportunities_in_range.map(&:id)).ids

    enquiries_on_email_blacklist = Enquiry.where(user_id: FeedbackOptOut.pluck(:user_id)).ids

    candidates = enquiries_in_range - enquiries_on_email_blacklist

    feedback_sender = EnquiryFeedbackSender.new

    candidates.each do |enquiry|
      feedback_sender.call(enquiry)
    end
  end
end
