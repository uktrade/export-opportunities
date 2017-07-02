class Admin::EnquiryResponsesController < Admin::BaseController
  include ActionController::Live
  # include VirusScannerHelper

  # Authentication is handled in routes.rb as ActionController::Live
  # and Devise don't play well together
  #
  # https://github.com/plataformatec/devise/issues/2332
  skip_before_action :authenticate_editor!

  def new
    enquiry_id = params.fetch(:id, nil)
    @enquiry = Enquiry.find(enquiry_id)

    @enquiry_response = EnquiryResponse.new
    @enquiry_response.enquiry = @enquiry
    authorize @enquiry_response
  end

  def create
    @enquiry_response = EnquiryResponse.new(enquiry_responses_params)
    @enquiry_response.editor_id = current_editor.id
    authorize @enquiry_response

    @enquiry_response.save
    response_documents = params[:response_documents]
    response_documents&.each do |response_document|
      resp = @enquiry_response.response_documents.new(email_attachment: response_document)
      if resp.valid?
        resp.save
      else
        resp.errors.messages.each do |error|
          key, message = error
          @enquiry_response.errors.add(key, message)
        end
      end
    end

    if @enquiry_response.errors.empty?
      EnquiryResponseSender.new.call(@enquiry_response, @enquiry_response.enquiry, @enquiry_response.response_documents.to_a)
      redirect_to admin_enquiries_path, notice: 'Reply sent successfully!'
    else
      flash[:error]
      params[:id] = @enquiry_response.enquiry_id
      @enquiry = @enquiry_response.enquiry
      render :new, status: :unprocessable_entity
    end
  end

  def enquiry_responses_params
    params.require(:enquiry_response).permit(:email_body, :editor_id, :enquiry_id, :response_document)
  end
end
