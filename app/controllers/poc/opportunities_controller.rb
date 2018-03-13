class Poc::OpportunitiesController < OpportunitiesController
  prepend_view_path 'app/views/poc'

  FIELD_VALUES_WHY = %w[sample sell distribute use].freeze
  POC_OPPORTUNITY_PROPS = %w[what why need industry keywords value specifications respond_by respond_to link].freeze

  def index
    @opportunity_summary_list = summary_list_by_industry
    @sort_column_name = sort_column
    @recent_opportunities = recent_opportunities
    @industries = industry_list
    render 'opportunities/index', layout: 'layouts/domestic'
  end

  def international
    render 'opportunities/international', layout: 'layouts/international'
  end

  def results
    @search_term = search_term
    @filters = SearchFilter.new(params)
    @sort_column_name = sort_column
    @opportunities = opportunity_search
    @industries = industry_list
    @subscription = subscription_form_details
    render 'opportunities/results', layout: 'layouts/domestic'
  end

  def new
    @process = { view: params[:view], fields: '', entries: {}, errors: {} }

    # Record any user entries (not in DB at this point).
    process_add_user_entries

    # Reverse order is intentional.
    process_step_four
    process_step_three
    process_step_two
    process_step_one

    @form = Poc::OpportunitiesFormPresenter.new(view_context, @process)
    case @process[:view]
    when 'step_4'
      render 'opportunities/verify', layout: 'layouts/international'
    when 'complete'
      # TODO: Something to save opportunity in DB
      # and redirect to somethere.
      redirect_to poc_international_path
    else
      render 'opportunities/new', layout: 'layouts/international'
    end
  end

  def show
    @opportunity = Poc::OpportunityPresenter.new(view_context, Opportunity.published.find(params[:id]))
    @page = Poc::PagePresenter.new(@opportunity.title_with_country || 'foo')
    render 'opportunities/show', layout: 'layouts/domestic'
  end

  private def process_add_user_entries
    POC_OPPORTUNITY_PROPS.each do |prop|
      @process[:entries][prop] = params[prop]
    end
  end

  private def process_step_one
    if @process[:view].eql? 'step_1'
      # TODO: Validate step_1 entries
      # If errors view should remain as step_1

      case @process[:entries]['what']
      when 'products'
        @process[:view] = 'step_2'
        @process[:fields] = 'step_2'
      when 'services'
        @process[:view] = 'step_3'
        @process[:fields] = 'step_3.2'
      when 'tender'
        @process[:view] = 'step_3'
        @process[:fields] = 'step_3.3'
      else
        @process[:view] = 'step_3'
        @process[:fields] = 'step_3.1'
      end
    end
  end

  private def process_step_two
    if @process[:view].eql? 'step_2'
      # TODO: Validate step_2 entries
      # If errors view should remain as step_2

      @process[:view] = 'step_3'
      @process[:fields] = 'step_3.1'
    end
  end

  private def process_step_three
    if @process[:view].eql? 'step_3'
      # TODO: Validate step_3 entries
      # If errors view should remain as step_3

      @process[:view] = 'step_4'
    end
  end

  private def process_step_four
    if @process[:view].eql? 'step_4'
      # TODO: Validate step_4 entries
      # If errors view should remain as step_4

      @process[:view] = 'complete'
    end
  end

  private def sort
    # set sort_order
    if @sort_column_name
      sort_order = @sort_column_name == 'response_due_on' ? 'asc' : 'desc'
    end

    if atom_request?
      OpportunitySort.new(default_column: 'updated_at', default_order: 'desc')
    else
      OpportunitySort.new(default_column: 'response_due_on', default_order: 'asc')
        .update(column: @sort_column_name, order: sort_order)
    end
  end

  private def sort_column
    # If user is using keyword to search
    if params.key?(:isSearchAndFilter) && params[:s].present?
      'relevance'
    # If user is filtering a search
    elsif params[:sort_column_name]
      params[:sort_column_name]
    else
      'response_due_on'
    end
  end

  private def opportunity_search
    per_page = Opportunity.default_per_page
    query = Opportunity.public_search(
      search_term: @search_term,
      filters: @filters,
      sort: sort
    )

    if atom_request?
      query = query.records
      query = query.page(params[:paged]).per(per_page)
      query = AtomOpportunityQueryDecorator.new(query, view_context)
      results = query
    else
      query = query.page(params[:paged]).per(per_page)
      results = query.records
    end

    Poc::OpportunitiesSearchResultPresenter.new(view_context, results, query.records.total, per_page)
  end

  # Get 5 most recent only
  private def recent_opportunities
    per_page = 5
    query = Opportunity.public_search(
      search_term: nil,
      filters: SearchFilter.new,
      sort: OpportunitySort.new(default_column: 'updated_at', default_order: 'desc')
    )
    query = query.page(params[:paged]).per(per_page)

    Poc::OpportunitiesSearchResultPresenter.new(view_context, query.records, query.records.total, per_page)
  end

  # TODO: How are the featured industries chosen?
  private def summary_list_by_industry
    # Food and drink    = id(14)
    # Retail and luxury = id(30)
    # Business and consumer services = id(4)
    # Software and computer srvices = id(32)
    # Creative and media = id(9)
    # Chemicals = id(5)

    @query = Sector.where(id: [14, 30, 4, 32, 9, 5])
  end

  private def industry_list
    @query = Sector.all
  end

  private def subscription_form_details
    form = SubscriptionForm.new(
      query: {
        search_term: @search_term,
        sectors: @filters.sectors,
        types: @filters.types,
        countries: @filters.countries,
        values: @filters.values,
      }
    )

    { form: form, description: SubscriptionPresenter.new(form).description }
  end
end
