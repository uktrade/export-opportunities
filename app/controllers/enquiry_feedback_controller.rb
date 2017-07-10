class EnquiryFeedbackController < ApplicationController
  rescue_from EncryptedParams::CouldNotDecrypt, with: :not_found

  def new
    # @enquiry_feedback = EnquiryFeedback.find(enquiry_feedback_params[:id])
    @enquiry_feedback = EnquiryFeedback.first

    if @enquiry_feedback.responded_at.nil?
      @enquiry_feedback.update!(
        initial_response: enquiry_feedback_params[:response],
        responded_at: Time.zone.now
      )
    end
  end

  # impact email feedback form submit
  def patch
    @enquiry_feedback_form = EnquiryFeedback.find(params[:id])

    @enquiry_feedback_form.update!(
      message: params[:enquiry_feedback][:message]
    )
    redirect_to '/', notice: 'Thanks, your feedback has been recorded'
  end

  private

  def enquiry_feedback_params
    @_enquiry_feedback_params ||= EncryptedParams.decrypt(params[:q])
  end
end
