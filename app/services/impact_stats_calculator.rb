class ImpactStatsCalculator
  def call(date_from, date_to)
    sent_date_range = (date_from..date_to)
    responded_date_range = (date_from..Time.zone.now)
    sent = EnquiryFeedback.where(created_at: sent_date_range).count
    eq = EnquiryFeedback.where.not(responded_at: nil).where(created_at: sent_date_range)
    eq_responded = eq.where(responded_at: responded_date_range)
    responded = eq_responded.count
    responded_with_feedback = eq_responded.where.not(message: nil).count

    option0 = eq_responded.where(initial_response: 0).count
    option1 = eq_responded.where(initial_response: 1).count
    option2 = eq_responded.where(initial_response: 2).count
    option3 = eq_responded.where(initial_response: 3).count
    option4 = eq_responded.where(initial_response: 4).count

    OpenStruct.new(
      sent: sent,
      responded: responded,
      responded_with_feedback: responded_with_feedback,
      option_0: option0,
      option_1: option1,
      option_2: option2,
      option_3: option3,
      option_4: option4
    )
  end
end
