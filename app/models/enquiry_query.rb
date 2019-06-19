class EnquiryQuery
  attr_reader :count, :enquiries

  def initialize(scope: Enquiry.all, status: nil, filters: NullFilter.new,
    sort:, page: 1, per_page: 10, search_query: '', service_provider: '')
    @scope = scope

    @status = status

    @filters = filters
    @sort = sort
    @page = page
    @per_page = per_page
    @search_query = search_query
    @service_provider = service_provider

    @enquiries = fetch_enquiries
  end

  private

    def fetch_enquiries
      query = if @sort.column == 'opportunity' && !status_selected
                @scope.joins(:opportunity)
              else
                @scope.distinct
              end

      order_sql = if @sort.column == 'opportunity'
                    @count = query.count
                    "opportunities.title #{@sort.order} NULLS LAST"
                  else
                    @count = query.count(:all)
                    "enquiries.#{@sort.column} #{@sort.order} NULLS LAST"
                  end
      query = query.order(order_sql)

      if @status == 'replied'
        query = query.joins('left outer join enquiry_responses on enquiry_responses.enquiry_id=enquiries.id') unless @sort.column == 'opportunity'
        query = query.where('enquiry_responses.id is not null and completed_at is not null')
      elsif @status == 'not_replied'
        query = query.joins('left outer join enquiry_responses on enquiry_responses.enquiry_id=enquiries.id') unless @sort.column == 'opportunity'
        query = query.where('enquiry_responses.id is null or completed_at is null')
      end

      if @search_query.present?
        query = query.joins(:opportunity).where('LOWER(opportunities.title) LIKE LOWER(?) OR
          LOWER(company_name) LIKE LOWER(?)', "%#{@search_query}%", "%#{@search_query}%")
      end

      if @service_provider.present?
        sp = ServiceProvider.where('LOWER(name) LIKE LOWER(?)', "%#{@service_provider}%")
        query = query.joins(:opportunity).where(opportunities: { service_provider: sp })
      end

      # Secondary sort order to prevent pagination weirdness
      query = query.order(created_at: :desc)

      # Without an argument, .count will produce invalid SQL in this context

      query.page(@page).per(@per_page)
    end

    def status_selected
      @status == 'replied' || @status == 'not_replied'
    end
end
