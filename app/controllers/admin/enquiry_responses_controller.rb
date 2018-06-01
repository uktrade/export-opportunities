class Admin::EnquiryResponsesController < Admin::BaseController
  include ApplicationHelper
  include ActionController::Live

  # Authentication is handled in routes.rb as ActionController::Live
  # and Devise don't play well together
  #
  # https://github.com/plataformatec/devise/issues/2332
  skip_before_action :authenticate_editor!, raise: false

  def new
    @enquiry ||= Enquiry.find(params.fetch(:id, nil))
    @companies_house_url ||= companies_house_url(@enquiry.company_house_number)
    @enquiry_response = if EnquiryResponse.where(enquiry_id: @enquiry.id).first.present?
                          EnquiryResponse.where(enquiry_id: @enquiry.id).first
                        else
                          EnquiryResponse.new
                        end
    @enquiry_response.enquiry = @enquiry
    @respond_by_date = @enquiry.created_at + 7.days
    authorize @enquiry_response
  end

  def create
    @enquiry_response = EnquiryResponse.new(enquiry_responses_params)
    create_or_update
  end

  def enquiry_responses_params
    ActionController::Base.helpers.sanitize params[:enquiry_response][:email_body]
    ActionController::Base.helpers.sanitize params[:enquiry_response][:signature]

    params.require(:enquiry_response).permit(:id, :created_at, :updated_at, :email_attachment, :email_body, :editor_id, :enquiry_id, :signature, :documents, :response_type, :completed_at, attachments: [id: {}])
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

  def email_send(enquiry_response_id = nil)
    enquiry_response_id ||= params[:enquiry_response_id]
    enquiry_response = EnquiryResponse.find(enquiry_response_id)
    authorize enquiry_response

    enquiry_response['completed_at'] = Time.zone.now
    enquiry_response.save!

    EnquiryResponseSender.new.call(enquiry_response, enquiry_response.enquiry)

    redirect_to admin_enquiries_path(reply_sent: true)
  end

  def logged_in_editor
    current_editor
  end

  private

  def create_or_update
    @enquiry_response.editor_id = logged_in_editor.id

    authorize @enquiry_response
    if @enquiry_response.errors.empty? && @enquiry_response.valid?
      @enquiry_response.save

      enquiry_response_type = @enquiry_response.response_type
      @web_view = true
      case enquiry_response_type
      when 1
        render 'enquiry_response_mailer/_right_for_opportunity'
      when 3
        render 'enquiry_response_mailer/_not_right_for_opportunity'
      when 4
        email_send(@enquiry_response.id)
      when 5
        email_send(@enquiry_response.id)
      end
    else
      @enquiry = @enquiry_response.enquiry
      @companies_house_url = companies_house_url(@enquiry.company_house_number)
      @respond_by_date = @enquiry.created_at + 7.days

      render :new, status: :unprocessable_entity
    end
  end
end
