class Poc::OpportunitiesController < OpportunitiesController
  prepend_view_path 'app/views/poc'

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
    render 'opportunities/new', layout: 'layouts/international'
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
    query = Opportunity.public_search(
      search_term: @search_term,
      filters: @filters,
      sort: sort
    )

    if atom_request?
      per_page = 25
      query = query.records
      query = query.page(params[:paged]).per(25)
      query = AtomOpportunityQueryDecorator.new(query, view_context)
    else
      per_page = Opportunity.default_per_page
      query = query.page(params[:paged]).per(per_page)
      query.records
    end

    Poc::OpportunitiesSearchResultPresenter.new(view_context, query, query.records.total, per_page)
  end

  # Get 5 most recent only
  private def recent_opportunities
    @query = Opportunity.public_search(
      search_term: nil,
      filters: SearchFilter.new,
      sort: sort
    )
    per_page = Opportunity.default_per_page
    @query = @query.page(params[:paged]).per(per_page)
    @query.records

    #opportunities = Opportunity.all.order(:created_at)
    #Poc::OpportunitiesSearchResultPresenter.new(view_context, opportunities.limit(5), opportunities.count, 5)
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
