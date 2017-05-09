class EnquiryFeedbackController < ApplicationController
  rescue_from EncryptedParams::CouldNotDecrypt, with: :not_found

  def new
    pp "enq feedback params:"
    pp enquiry_feedback_params
    @enquiry_feedback = EnquiryFeedback.find(enquiry_feedback_params[:id])

    if @enquiry_feedback.responded_at.nil?
      @enquiry_feedback.update!(
        initial_response: enquiry_feedback_params[:response],
        responded_at: Time.zone.now
      )
    end
  end

  def patch
    
  end

  private

  def enquiry_feedback_params
    @_enquiry_feedback_params ||= EncryptedParams.decrypt(params[:q])
  end
end
