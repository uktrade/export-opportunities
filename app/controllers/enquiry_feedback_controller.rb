class EnquiryFeedbackController < ApplicationController
  rescue_from EncryptedParams::CouldNotDecrypt, with: :not_found

  def new
    content = get_content('enquiry_feedback.yml')
    response = enquiry_feedback_params[:response] || 'unknown'
    @enquiry_feedback = EnquiryFeedback.find(enquiry_feedback_params[:id])
    @enquiry_feedback.update!(
      initial_response: enquiry_feedback_params[:response],
      responded_at: Time.zone.now
    )

    @response_text = content[response]
    render 'enquiry_feedback/new', layout: 'general', locals: {
      content: content,
    }
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
      @enquiry_feedback_params ||= EncryptedParams.decrypt(params[:q])
    end
end
