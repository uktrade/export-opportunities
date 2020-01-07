class Admin::OpportunitiesController < Admin::BaseController
  OPPORTUNITIES_PER_PAGE = 50
  after_action :verify_authorized, except: [:help]

  include ApplicationHelper
  include SortableHelper

  def index
    @filters = OpportunityFilters.new(filter_params)
    @available_status = Opportunity.statuses.keys
    previewer_or_uploader = pundit_user.uploader? || pundit_user.previewer?

    session[:opportunity_filters] = filter_params

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

    render layout: 'admin_transformed', locals: {
      content: get_content('admin/opportunities.yml'),
    }
  end

  def show
    content = get_content('opportunities/show.yml', 'admin/opportunities.yml')
    @opportunity = Opportunity.includes(:enquiries).find(params[:id])
    @enquiries_cutoff = 20
    @comment_form = OpportunityCommentForm.new(opportunity: @opportunity, author: current_editor)
    @history = OpportunityHistory.new(opportunity: @opportunity)
    @show_enquiries = policy(@opportunity).show_enquiries?

    authorize @opportunity
    render layout: 'admin_transformed', locals: {
      content: content,
    }
  end

  def new
    content = get_content('opportunities/show.yml', 'admin/opportunities.yml')
    @opportunity = Opportunity.new
    @save_to_draft_button = policy(@opportunity).uploader_previewer?
    @editor = current_editor
    load_options_for_form(@opportunity)
    setup_opportunity_contacts(@opportunity)
    authorize @opportunity
    render layout: 'admin_transformed', locals: {
      content: content,
    }
  end

  def create
    content = get_content('opportunities/show.yml', 'admin/opportunities.yml')
    status = if params[:commit] == content['submit_draft']
               :draft
             else
               :pending
             end

    @opportunity = CreateOpportunity.new(current_editor, status, :post).call(create_opportunity_params)
    authorize @opportunity

    if @opportunity.errors.empty?
      if status == :pending
        redirect_to admin_opportunity_path(@opportunity), notice: %(Created opportunity "#{@opportunity.title}")
      elsif status == :draft
        redirect_to admin_opportunity_path(@opportunity), notice: %(Saved to draft: "#{@opportunity.title}")
      end
    else
      @editor = current_editor

      load_options_for_form(@opportunity)
      setup_opportunity_contacts(@opportunity)
      render :new, status: :unprocessable_entity, layout: 'admin_transformed', locals: {
        content: content,
      }
    end
  end

  def edit
    content = get_content('opportunities/show.yml', 'admin/opportunities.yml')
    @opportunity = Opportunity.includes(comments: [:author]).find(params[:id])
    @comment_form = OpportunityCommentForm.new(opportunity: @opportunity, author: current_editor)
    @history = OpportunityHistory.new(opportunity: @opportunity)
    @editor = current_editor

    load_options_for_form(@opportunity)

    setup_opportunity_contacts(@opportunity)
    authorize @opportunity
    render layout: 'admin_transformed', locals: {
      content: content,
    }
  end

  def update
    content = get_content('opportunities/show.yml', 'admin/opportunities.yml')
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
      render :edit, layout: 'admin_transformed', locals: {
        content: content,
      }
    end
  end

  def help; end

  private

    def load_options_for_form(opportunity)
      @request_types = Opportunity.request_types.keys
      @tender_bool = %w[true false]
      @request_usages = Opportunity.request_usages.keys
      @supplier_preferences = SupplierPreference.all
      @service_providers = ServiceProvider.all.order(:name)
      @service_provider = opportunity.service_provider || current_editor.service_provider
      @countries = Country.all.order(:name)
      @default_country = @service_provider.country&.id if opportunity.countries.empty?
      @sectors = Sector.all.order(:name)
      @types = Type.all.order(:name)
      @values = Value.all.order(:slug)
      @enquiry_interactions = Opportunity.enquiry_interactions.keys
      @ragg = opportunity.ragg
      @opportunity_cpvs = opportunity.cpvs
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
      params.require(:opportunity).permit(:title, :slug, { country_ids: [] }, { sector_ids: [] }, { type_ids: [] }, { supplier_preference_ids: [] }, { opportunity_cpv_ids: [] }, :opportunity_cpv_ids, :response_due_on, :request_type, :tender, :request_usage, :enquiry_interaction, :value_ids, :teaser, :description, { contacts_attributes: contacts_attributes }, :service_provider_id, :ragg, :buyer_name, :buyer_address, :language, :tender_value, :source, :tender_content, :tender_url, :target_url, :tender_source, :tender_value, :ocid, :industry_id, :industry_scheme)
    end

    def create_contacts_attributes
      %i[name email]
    end

    def update_contacts_attributes
      %i[name email id opportunity_id]
    end

    def filter_params
      params.permit(:status, { sort: %i[column order] }, :hide_expired, :s, :paged)
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
        @hide_expired = if params[:hide_expired] && params[:hide_expired] == 'false'
                          false
                        else
                          true
                        end

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
