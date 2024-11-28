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
    @csat = CustomerSatisfactionFeedback.find(params['id'])
    csat_params = params.require(:csat)
    unless @csat.update(csat_params)
      render :create
    end
  end

  def cancel
    render :update
  end
end
