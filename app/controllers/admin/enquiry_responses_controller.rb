class Admin::EnquiryResponsesController < Admin::BaseController
  include ApplicationHelper
  include ActionController::Live

  # Authentication is handled in routes.rb as ActionController::Live
  # and Devise don't play well together
  #
  # https://github.com/plataformatec/devise/issues/2332
  skip_before_action :authenticate_editor!

  def new
    enquiry_id = params.fetch(:id, nil)
    @enquiry = Enquiry.find(enquiry_id)
    @companies_house_url = companies_house_url(@enquiry.company_house_number)

    @enquiry_response = EnquiryResponse.new
    @enquiry_response.enquiry = @enquiry
    authorize @enquiry_response
  end

  def create
    @enquiry_response = EnquiryResponse.new(enquiry_responses_params)
    @enquiry_response.editor_id = current_editor.id

    authorize @enquiry_response
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
