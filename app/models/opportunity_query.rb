class OpportunityQuery
  attr_reader :count, :opportunities

  def initialize(scope: Opportunity.all, status: nil, hide_expired: false, search_term: nil, search_method: :fuzzy_match, filters: NullFilter.new, sort:, page: 1, per_page: 10, ignore_sort: false)
    @scope = scope

    @status = status
    @hide_expired = hide_expired

    @search_term = search_term
    @search_method = search_method
    @filters = filters
    @sort = sort
    @page = page
    @per_page = per_page
    @ignore_sort = ignore_sort

    @opportunities = fetch_opportunities
  end

  private def fetch_opportunities
    query = if @search_term && @sort.column == 'service_provider_name'
              @scope.joins(:service_provider)
            else
              @scope.distinct
            end

    unless @ignore_sort
      if @sort.column == 'service_provider_name'
        order_sql = "service_providers.name #{@sort.order} NULLS LAST"
      else
        # We trust these values because they were whitelisted in OpportunitySort
        order_sql = "opportunities.#{@sort.column} #{@sort.order} NULLS LAST"
      end
      query = query.order(order_sql)
    end

    if @search_term.present?
      query = query.public_send(@search_method, @search_term)

      # Because we will order by search rank AND we are running a DISTINCT
      # query, Postgres needs to have search rank in the SELECT clause.
      query = query&.with_pg_search_rank
    end

    return Opportunity.none if query.nil?

    query = query.where(status: Opportunity.statuses[@status]) if @status

    query = query.applicable if @hide_expired

    # Secondary sort order to prevent pagination weirdness
    query = query.order(created_at: :desc)

    query = query.joins(:sectors).merge(Sector.where(slug: @filters.sectors)) if @filters.sectors.present?
    query = query.joins(:countries).merge(Country.where(slug: @filters.countries)) if @filters.countries.present?
    query = query.joins(:types).merge(Type.where(slug: @filters.types)) if @filters.types.present?
    query = query.joins(:values).merge(Value.where(slug: @filters.values)) if @filters.values.present?

    # Without an argument, .count will produce invalid SQL in this context
    @count = query.count(:all)

    query = query.page(@page).per(@per_page)

    query
  end
end
