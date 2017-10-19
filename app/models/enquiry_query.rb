class EnquiryQuery
  attr_reader :count, :enquiries

  def initialize(scope: Enquiry.all, status: nil, filters: NullFilter.new, sort:, page: 1, per_page: 10)
    @scope = scope

    @status = status

    @filters = filters
    @sort = sort
    @page = page
    @per_page = per_page

    @enquiries = fetch_enquiries
  end

  private def fetch_enquiries
    query = @scope.distinct

    order_sql = "enquiries.#{@sort.column} #{@sort.order} NULLS LAST"
    query = query.order(order_sql)

    if @status == 'replied'
      query = query.joins('left outer join enquiry_responses on enquiry_responses.enquiry_id=enquiries.id')
      query = query.where('enquiry_responses.id is not null')
    elsif @status == 'not_replied'
      query = query.joins('left outer join enquiry_responses on enquiry_responses.enquiry_id=enquiries.id')
      query = query.where('enquiry_responses.id is null')
    end

    # Secondary sort order to prevent pagination weirdness
    query = query.order(created_at: :desc)

    # Without an argument, .count will produce invalid SQL in this context

    @count = query.count(:all)

    query.page(@page).per(@per_page)
  end
end
