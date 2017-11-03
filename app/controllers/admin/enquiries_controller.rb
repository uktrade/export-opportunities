class Admin::EnquiriesController < Admin::BaseController
  ENQUIRIES_PER_PAGE = 5
  include ApplicationHelper
  after_action :verify_authorized, except: [:help]

  def index
    @filters = EnquiryFilters.new(filter_params)

    session[:enquiry_filters] = filter_params

    query = EnquiryQuery.new(
        scope: policy_scope(Enquiry).includes(:enquiry_response),
        status: @filters.selected_status,
        sort: @filters.sort,
        page: @filters.page,
        per_page: ENQUIRIES_PER_PAGE
    )

    @enquiry_form = enquiry_form
    @enquiries = query.enquiries

    authorize @enquiries

    respond_to do |format|
      format.html do
        @enquiries = @enquiries.includes(:opportunity).page(params[:paged])

        @next_enquiry = next_enquiry if params[:reply_sent]
      end
      format.csv do
        @enquiries = policy_scope(Enquiry).all.order(created_at: :desc)
        @enquiries = @enquiries.where(created_at: @enquiry_form.from..@enquiry_form.to) if @enquiry_form.dates?

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

  def help; end

  class EnquiryFilters
    attr_reader :selected_status, :sort, :page ##

    def initialize(params)
      @selected_status = params[:status]
      @sort_params = params.fetch(:sort, {})

      @sort = EnquirySort.new(default_column: 'created_at', default_order: 'desc').update(column: @sort_params[:column], order: @sort_params[:order])

      @page = params[:paged]
    end

    private

    def alphanumeric_words_and_emails
      /([a-zA-Z0-9\.\@\-\_]*\w)/
    end
  end

  private def enquiry_form
    @enquiry_form ||= EnquiryForm.new(params.permit(created_at_from: [:year, :month, :day], created_at_to: [:year, :month, :day]))
  end

  private def download_filename
    "eig-enquiries-#{enquiry_form.from.strftime('%Y-%m-%d')}-#{enquiry_form.to.strftime('%Y-%m-%d')}.csv"
  end

  private def filter_params
    params.permit(:status, { sort: [:column, :order] }, :company_name, :created_at, :paged)
  end

  private def filter_status(current_user)
    @editor = Editor.find(current_user)
    @available_status = []
    Opportunity.statuses.each do |name, _|
      if name == 'draft'
        @available_status << name if policy(@editor).draft_view_state?
      else
        @available_status << name
      end
    end
  end

  def next_enquiry
    query = EnquiryQuery.new(
        scope: policy_scope(Enquiry).includes(:enquiry_response),
        sort: EnquirySort.new(default_column: 'created_at', default_order: 'asc'),
        page: 1,
        per_page: 100
    )
    enquiries = query.enquiries

    enquiries.each do |enq|
      return { url: admin_enquiry_url(enq), id: enq['id'] } if !enq.enquiry_response || enq.enquiry_response['completed_at'].blank?
    end
    nil
  end
end
