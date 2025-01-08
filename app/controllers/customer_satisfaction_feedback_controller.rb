# frozen_string_literal: true

class CustomerSatisfactionFeedbackController < ApplicationController
  before_action :require_sso!

  # POST /enquiries/:slug/feedback
  def create
    rating_params = params.require(:feedback)
    @csat = CustomerSatisfactionFeedback.new(rating_params)
    @csat.url = request.path

    unless @csat.save
      render 'enquiries/create.html'
    end
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
