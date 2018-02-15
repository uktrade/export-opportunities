class Poc::OpportunitiesController < OpportunitiesController
  prepend_view_path 'app/views/poc'

  def index
    @opportunity_summary_list = summary_list_by_industry
    @sort_column_name = column_name
    @opportunities = recent_opportunities
    @industries = industry_list
    render "opportunities/index", layout: "layouts/landing_domestic"
  end

  def international
    render "opportunities/international", layout: "layouts/landing_international"
  end

  def results
    @search_term = search_term
    @filters = SearchFilter.new(params)
    @sort_column_name = column_name
    @opportunities = opportunity_search
    @industries = industry_list
    @subscription_form = SubscriptionForm.new(
      query: {
        search_term: @search_term,
        sectors: @filters.sectors,
        types: @filters.types,
        countries: @filters.countries,
        values: @filters.values,
      }
    )
    @description = SubscriptionPresenter.new(@subscription_form).description

    render "opportunities/results", layout: "layouts/results"
  end

  private def sort
    column = @sort_column_name

    # set sort_order
    if column
      sort_order = column == 'response_due_on' ? 'asc' : 'desc'
    end

    if atom_request?
      OpportunitySort.new(default_column: 'updated_at', default_order: 'desc')
    else
      OpportunitySort.new(default_column: 'response_due_on', default_order: 'asc')
        .update(column: column, order: sort_order)
    end
  end

  private def column_name
    # Default sort column
    column = 'response_due_on'

    # If user is using keyword to search
    if params.key?(:isSearchAndFilter) && params[:s].present?
      column = 'relevance'
    end

    # If user is filtering a search
    column = params[:sort_column_name] if params[:sort_column_name]
  end

  private def opportunity_search
    query = Opportunity.public_search(
      search_term: @search_term,
      filters: @filters,
      sort: sort
    )

    if atom_request?
      query = query.records
      query = query.page(params[:paged]).per(25)
      query = AtomOpportunityQueryDecorator.new(query, view_context)
      results = query
    else
      @count = query.records.total
      query = query.page(params[:paged]).per(Opportunity.default_per_page)
      results = query.records
    end

    return results
  end

  # TODO: Needs to get most recent only
  private def recent_opportunities 
    @query = Opportunity.public_search(
      search_term: nil,
      filters: SearchFilter.new(),
      sort: sort
    )

		@query.records
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

end
