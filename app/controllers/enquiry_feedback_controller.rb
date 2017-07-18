class EnquiryFeedbackController < ApplicationController
  rescue_from EncryptedParams::CouldNotDecrypt, with: :not_found

  def new
    @enquiry_feedback = EnquiryFeedback.find(enquiry_feedback_params[:id])

    if @enquiry_feedback.responded_at.nil?

      @enquiry_feedback.update!(
        initial_response: enquiry_feedback_params[:response],
        responded_at: Time.zone.now
      )
    end

    @response_text = response_display_text(enquiry_feedback_params[:response])
    render 'enquiry_feedback/new'
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

  def response_display_text(response)
    text = { won: 'I won the business',
      did_not_win: 'I didn\'t win the business',
      dont_know_outcome: 'I was contacted by the buyer but don\'t yet know the outcome',
      dontknow_want_to_say: 'I don\'t know or I don\'t want to say',
      no_response: 'I wasn\'t contacted by the buyer' }
    text[response]
  end
end
