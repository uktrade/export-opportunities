class FeedbackOptOutsController < ApplicationController
  rescue_from EncryptedParams::CouldNotDecrypt, with: :not_found
  before_action :require_sso!

  def create
    FeedbackOptOut.first_or_create(user_id: feedback_opt_out_params[:user_id])
  end

  private

    def feedback_opt_out_params
      @feedback_opt_out_params ||= EncryptedParams.decrypt(params[:q])
    end
end
