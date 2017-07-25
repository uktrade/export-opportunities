class ImpactStatsCalculator

  def call(date_from, date_to)
    date_range = (date_from..date_to)
    eq = EnquiryFeedback.where.not(responded_at: nil)
    eq_responded = eq.where(responded_at: date_range)
    sent = eq.where(created_at: date_range).count
    responded = eq_responded.count
    responded_with_feedback = eq_responded.where.not(message: nil).count

    option_0 = eq_responded.where(initial_response: 0).count
    option_1 = eq_responded.where(initial_response: 1).count
    option_2 = eq_responded.where(initial_response: 2).count
    option_3 = eq_responded.where(initial_response: 3).count
    option_4 = eq_responded.where(initial_response: 4).count

    OpenStruct.new(
      sent: sent,
      responded: responded,
      responded_with_feedback: responded_with_feedback,
      option_0: option_0,
      option_1: option_1,
      option_2: option_2,
      option_3: option_3,
      option_4: option_4,
    )
  end
end
