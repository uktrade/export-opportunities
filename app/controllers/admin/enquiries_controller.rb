class Admin::EnquiriesController < Admin::BaseController
  include ApplicationHelper
  include ActionController::Live

  # Authentication is handled in routes.rb as ActionController::Live
  # and Devise don't play well together
  #
  # https://github.com/plataformatec/devise/issues/2332
  skip_before_action :authenticate_editor!

  def index
    @enquiry_form = enquiry_form

    @enquiries = policy_scope(Enquiry).all.order(created_at: :desc)
    @enquiries = @enquiries.where(created_at: @enquiry_form.from..@enquiry_form.to) if @enquiry_form.dates?
    @enquiries.includes(:enquiry_response)

    authorize @enquiries

    respond_to do |format|
      format.html do
        @enquiries = @enquiries.includes(:opportunity).page(params[:paged])
      end
      format.csv do
        response.headers['Content-Disposition'] = "attachment; filename=\"#{download_filename}\""
        response.headers['Content-Type'] = 'text/csv'

        csv = EnquiryCSV.new(@enquiries)

        begin
          csv.each do |row|
            response.stream.write(row)
          end
        ensure
          response.stream.close
        end
      end
    end
  end

  def show
    enquiry_id = params.fetch(:id, nil)
    @enquiry = Enquiry.find(enquiry_id)
    @enquiry_response = EnquiryResponse.where(enquiry_id: enquiry_id).first
    @trade_profile_url = trade_profile(@enquiry.company_house_number)
    @companies_house_url = companies_house_url(@enquiry.company_house_number)
    authorize @enquiry
  end

  private def enquiry_form
    @enquiry_form ||= EnquiryForm.new(params.permit(created_at_from: [:year, :month, :day], created_at_to: [:year, :month, :day]))
  end

  private def download_filename
    "eig-enquiries-#{enquiry_form.from.strftime('%Y-%m-%d')}-#{enquiry_form.to.strftime('%Y-%m-%d')}.csv"
  end
end
