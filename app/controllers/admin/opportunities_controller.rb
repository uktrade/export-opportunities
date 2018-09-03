class Admin::OpportunitiesController < Admin::BaseController
  OPPORTUNITIES_PER_PAGE = 50
  after_action :verify_authorized, except: [:help]

  include ApplicationHelper
  include SortableHelper

  def index
    @filters = OpportunityFilters.new(filter_params)

    previewer_or_uploader = pundit_user.uploader? || pundit_user.previewer?

    session[:opportunity_filters] = filter_params
    session[:available_status] = filter_status(pundit_user.id)

    query = OpportunityQuery.new(
      scope: policy_scope(Opportunity).includes(:service_provider),
      status: @filters.selected_status,
      search_term: @filters.sanitized_search,
      search_method: :admin_match,
      sort: @filters.sort,
      previewer_or_uploader: previewer_or_uploader,
      hide_expired: @filters.hide_expired,
      page: @filters.page,
      per_page: OPPORTUNITIES_PER_PAGE,
      ignore_sort: @filters.ignore_sort?
    )

    @opportunities = query.opportunities
    authorize @opportunities
  end

  def show
    @opportunity = Opportunity.includes(:enquiries).find(params[:id])
    @enquiries_cutoff = 20
    @comment_form = OpportunityCommentForm.new(opportunity: @opportunity, author: current_editor)
    @history = OpportunityHistory.new(opportunity: @opportunity)

    @publishing_button_data = publishing_button_data(@opportunity)
    @drafting_button_data = drafting_button_data(@opportunity)
    @pending_button_data = pending_button_data(@opportunity)
    @show_trash_button = policy(@opportunity).trash?
    @show_enquiries = policy(@opportunity).show_enquiries?

    authorize @opportunity
  end

  def new
    content = get_content('admin/opportunities.yml')
    @opportunity = Opportunity.new
    @save_to_draft_button = policy(@opportunity).uploader_previewer?

    load_options_for_form(@opportunity)
    setup_opportunity_contacts(@opportunity)
    authorize @opportunity
    render layout: 'admin_transformed', locals: {
      content: content,
    }
  end

  def create
    opportunity_status = params[:commit] == 'Save to Draft' ? :draft : :pending

    @opportunity = CreateOpportunity.new(current_editor, opportunity_status, :post).call(create_opportunity_params)
    authorize @opportunity

    if @opportunity.errors.empty?
      if opportunity_status == :pending
        redirect_to admin_opportunities_path, notice: %(Created opportunity "#{@opportunity.title}")
      elsif opportunity_status == :draft
        redirect_to admin_opportunities_path, notice: %(Saved to draft: "#{@opportunity.title}")
      end
    else
      load_options_for_form(@opportunity)
      setup_opportunity_contacts(@opportunity)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    content = get_content('admin/opportunities.yml')
    @opportunity = Opportunity.includes(comments: [:author]).find(params[:id])
    @comment_form = OpportunityCommentForm.new(opportunity: @opportunity, author: current_editor)
    @history = OpportunityHistory.new(opportunity: @opportunity)

    load_options_for_form(@opportunity)

    setup_opportunity_contacts(@opportunity)

    authorize @opportunity
    render layout: 'admin_transformed', locals: {
      content: content,
    }
  end

  def update
    @opportunity = Opportunity.find(params[:id])
    authorize @opportunity

    @opportunity = UpdateOpportunity.new(@opportunity).call(update_opportunity_params)

    if @opportunity.errors.empty?
      redirect_to admin_opportunity_path(@opportunity), notice: %(Updated opportunity "#{@opportunity.title}")
    else
      @comment_form = OpportunityCommentForm.new(opportunity: @opportunity, author: current_editor)
      @history = OpportunityHistory.new(opportunity: @opportunity)

      load_options_for_form(@opportunity)
      setup_opportunity_contacts(@opportunity)
      render :edit
    end
  end

  def help; end

  private

  def load_options_for_form(opportunity)
    @request_types = Opportunity.request_types
    @supplier_preferences = SupplierPreference.all
    @countries = promote_elements_to_front_of_array(Country.all.order(:name), opportunity.countries.sort_by(&:name))
    @sectors = promote_elements_to_front_of_array(Sector.all.order(:name), opportunity.sectors.sort_by(&:name))
    @types = Type.all.order(:name)
    @values = Value.all.order(:name)
    @service_providers = ServiceProvider.all.order(:name)
    @selected_service_provider = opportunity.service_provider || current_editor.service_provider
    @ragg = opportunity.ragg
  end

  def setup_opportunity_contacts(opportunity)
    (Opportunity::CONTACTS_PER_OPPORTUNITY - opportunity.contacts.length).times do
      opportunity.contacts.build
    end
  end

  def create_opportunity_params
    opportunity_params(contacts_attributes: create_contacts_attributes)
  end

  def update_opportunity_params
    opportunity_params(contacts_attributes: update_contacts_attributes)
  end

  def opportunity_params(contacts_attributes:)
    params.require(:opportunity).permit(:title, :slug, { service_provider_ids: [] }, { country_ids: [] }, { sector_ids: [] }, { type_ids: [] }, :value_ids, :teaser, :response_due_on, :description, { contacts_attributes: contacts_attributes }, :service_provider_id, :ragg, :buyer_name, :buyer_address, :language, :tender_value, :source, :tender_content, :tender_url, :target_url, :tender_source, :tender_value, :ocid, :industry_id, :industry_scheme)
  end

  def create_contacts_attributes
    %i[name email]
  end

  def update_contacts_attributes
    %i[name email id opportunity_id]
  end

  ButtonData = Struct.new(:show, :text, :path, :params)

  def publishing_button_data(opportunity)
    path = admin_opportunity_status_path(opportunity)

    case opportunity.status
    when 'publish'
      ButtonData.new(policy(opportunity).publishing?, 'Unpublish', path, status: 'pending')
    when 'pending'
      ButtonData.new(policy(opportunity).publishing?, 'Publish', path, status: 'publish')
    when 'trash'
      ButtonData.new(policy(opportunity).restore?, 'Restore', path, status: 'pending')
    else
      ButtonData.new(false)
    end
  end

  def drafting_button_data(opportunity)
    path = admin_opportunity_status_path(opportunity)

    case opportunity.status
    when 'trash'
      ButtonData.new(policy(opportunity).draft?, 'Draft', path, status: 'draft')
    when 'pending'
      ButtonData.new(policy(opportunity).draft?, 'Draft', path, status: 'draft')
    else
      ButtonData.new(false)
    end
  end

  def pending_button_data(opportunity)
    path = admin_opportunity_status_path(opportunity)

    case opportunity.status
    when 'draft'
      ButtonData.new(policy(opportunity).uploader_previewer_restore?, 'Pending', path, status: 'pending')
    else
      ButtonData.new(false)
    end
  end

  private def filter_params
    params.permit(:status, { sort: %i[column order] }, :show_expired, :s, :paged)
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

  class OpportunityFilters
    attr_reader :selected_status, :sort, :hide_expired, :raw_search_term, :page

    def initialize(params)
      @selected_status = params[:status]
      @sort_params = params.fetch(:sort, {})

      @sort = if @selected_status == 'pending' && @sort_params.empty?
                OpportunitySort.new(default_column: 'ragg', default_order: 'asc')
              else
                OpportunitySort.new(default_column: 'created_at', default_order: 'desc').update(column: @sort_params[:column], order: @sort_params[:order])
              end
      @hide_expired = !params[:show_expired]
      # Allowing a non-sanitized search input past this layer **only** for the view.
      # The intent is not to give away how the inputs are being stripped to the user.
      @raw_search_term = params[:s]
      @page = params[:paged]
    end

    def sanitized_search
      return unless @raw_search_term
      @raw_search_term.gsub(alphanumeric_words_and_emails).to_a.join(' ')
    end

    def ignore_sort?
      @raw_search_term && @sort_params.empty?
    end

    private

    def alphanumeric_words_and_emails
      /([a-zA-Z0-9\.\@\-\_]*\w)/
    end
  end
end
