class FeedbackOptOutsController < ApplicationController
  rescue_from EncryptedParams::CouldNotDecrypt, with: :not_found

  def create
    FeedbackOptOut.first_or_create(user_id: feedback_opt_out_params[:user_id])
  end

  private

  def feedback_opt_out_params
    @_feedback_opt_out_params ||= EncryptedParams.decrypt(params[:q])
  end
end
