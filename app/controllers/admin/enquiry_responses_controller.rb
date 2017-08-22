class Admin::EnquiryResponsesController < Admin::BaseController
  include ApplicationHelper
  include ActionController::Live

  # Authentication is handled in routes.rb as ActionController::Live
  # and Devise don't play well together
  #
  # https://github.com/plataformatec/devise/issues/2332
  skip_before_action :authenticate_editor!

  def new
    @enquiry ||= Enquiry.find(params.fetch(:id, nil))
    @companies_house_url ||= companies_house_url(@enquiry.company_house_number)

    @enquiry_response ||= EnquiryResponse.where(enquiry_id: @enquiry.id).first ? EnquiryResponse.where(enquiry_id: @enquiry.id).first : EnquiryResponse.new
    @enquiry_response.enquiry ||= @enquiry
    @respond_by_date ||= @enquiry.created_at + 5.days
    authorize @enquiry_response
  end

  def create
    @enquiry_response = EnquiryResponse.new(enquiry_responses_params)
    create_or_update
  end

  def enquiry_responses_params
    byebug
    params.require(:enquiry_response).permit(:id, :created_at, :updated_at, :email_attachment, :email_body, :editor_id, :enquiry_id, :signature, :documents, :response_type, attachments: [id: {} ])
  end

  def preview
    Rails.logger.debug 'showing enquiry response'
  end

  def update
    enquiry_id = enquiry_responses_params['enquiry_id']
    @enquiry_response = EnquiryResponse.where(enquiry_id: enquiry_id.to_i).first
    @enquiry_response.update!(enquiry_responses_params)
    create_or_update
  end

  # def send
  #   EnquiryResponseSender.new.call(@enquiry_response, @enquiry_response.enquiry)
  #   redirect_to admin_enquiries_path, notice: 'Reply sent successfully!'
  # end

  private

  def create_or_update
    @enquiry_response.editor_id = current_editor.id

    authorize @enquiry_response
    if @enquiry_response.errors.empty? && @enquiry_response.valid?
      @enquiry_response.save

      render :show, enquiry_response: @enquiry_response
    else
      @enquiry = @enquiry_response.enquiry
      @companies_house_url = companies_house_url(@enquiry.company_house_number)
      @respond_by_date = @enquiry.created_at + 5.days

      render :new, status: :unprocessable_entity
    end
  end
end
