class OpportunitySearch
  # 
  # Provides search functionality for Opportunities
  #
  # Input:
  #   term:    String search term
  #   filter:  Filter, contains sanitised input from filters
  #   sort:    OpportunitySort, contains sanitised data from sort dropdown
  #   limit:   Int number of results to cap at, per shard
  #
  # Accessors
  #   results: ElasticSearch object with Opportunity results
  #   total:   Int number of results
  #   total_without_limit:  Int number of results with out cap
  #

  attr_accessor :results, :total, :count_without_limit

  def initialize(term: '', filter: NullFilter.new(),
      sort: OpportunitySort.new(default_column: 'first_published_at',
        default_order: 'desc'), boost: false, limit: 100)
    @term, @filter, @sort, @boost, @limit = term, filter, sort, boost, limit
    perform
  end

  private

    def perform
      search = Opportunity.public_search(
        search_term: @term,
        filters: @filter,
        sort: @sort,
        limit: @limit,
        dit_boost_search: @boost
      )
      @results = search[:search]
      @total = @results.size
      @total_without_limit = search[:total_without_limit]
    end
end