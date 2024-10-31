# frozen_string_literal: true

class CustomerSatisfactionFeedbackController < ApplicationController
  before_action :require_sso!

  # POST /enquiries/:slug/feedback
  def create
    rating_params = params.require(:feedback).permit(:satisfaction_rating)
    @csat = CustomerSatisfactionFeedback.new(rating_params)
    @csat.url = request.path
    @csat.save!
  end

  # PATCH /enquiries/:slug/feedback
  def update
    feedback = CustomerSatisfactionFeedback.find(params['id'])
    feedback_params = params.require(:feedback)
    feedback.update!(feedback_params)
  end
end
