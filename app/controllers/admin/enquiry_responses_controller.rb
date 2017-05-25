class Admin::EnquiryResponsesController < Admin::BaseController
  include ActionController::Live

  # Authentication is handled in routes.rb as ActionController::Live
  # and Devise don't play well together
  #
  # https://github.com/plataformatec/devise/issues/2332
  skip_before_action :authenticate_editor!

  def new
    enquiry_id = params.fetch(:id, nil)
    @enquiry = Enquiry.find(enquiry_id)

    @enquiry_response = EnquiryResponse.new
    # authorize @enquiry_response
  end

  def create
    @enquiry_response = EnquiryResponse.new(enquiry_responses_params)
    @enquiry_response.editor_id = current_editor.id
    if @enquiry_response.errors.empty?
      @enquiry_response.save
      EnquiryResponseSender.new.call(@enquiry_response, @enquiry_response.enquiry)
      redirect_to admin_enquiries_path, notice: 'Reply sent successfully!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def enquiry_responses_params
    params.require(:enquiry_response).permit(:email_body, :editor_id, :enquiry_id)
  end
end
