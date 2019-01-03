require 'elasticsearch'

class Search

  # 
  # Provides search functionality for Opportunities
  #
  # Input: params: url parameters Hash, with accepts keys:
  #                s:                 search term
  #                regions:           url-encoded array of slugs of regions
  #                countries:         url-encoded array of slugs of countries
  #                sources:           url-encoded array of slugs of sources
  #                types:             url-encoded array of slugs of types
  #                sort_column_name:  column to filter on
  #                paged:             Which page number to return results on
  #        limit:  Int number of results to cap at, per shard
  #        results_only: Boolean, if true only provides results of search and not
  #                      search metadata and input data
  #
  def initialize(params, limit: 100, results_only: false)
    @term   = clean_term(params[:s])
    @filter = SearchFilter.new(params)
    @sort   = clean_sort(params)
    @boost  = params['boost_search'].present? 
    @limit  = limit
    @paged  = params[:paged]
    @results_only = results_only
  end

  def run
    query = build_query
    search_query = query[0]
    search_sort  = query[1]
    limit        = query[2]
    perform(search_query, search_sort, limit)
  end

  # -- Parameter Sanitisation --

  # Cleans the term parameter
  def clean_term(term = nil)
    term.present? ? term.delete("'").gsub(alphanumeric_words).to_a.join(' ') : ""
  end

  # Regex to identify suitable words for term parameter
  def alphanumeric_words
    /([a-zA-Z0-9]*\w)/
  end

  # Builds OpportunitySort object based on filter
  def clean_sort(params)
    case params[:sort_column_name]
    when 'response_due_on' # Soonest to end first
      column = 'response_due_on' and order = 'asc'
    when 'first_published_at' # Newest posted to oldest
      column = 'first_published_at' and order = 'desc' 
    when 'updated_at' # Most recently updated
      column = 'updated_at' and order = 'desc' 
    when 'relevance' # Most relevant first
      column = 'response_due_on' and order = 'asc' # TODO: Add relevance. Temporary fix
    else
      column = 'response_due_on' and order = 'asc'
    end
    OpportunitySort.new(default_column: column, default_order: order)
  end

  # -- Runs the appropriate search --

  def build_query
    if search_includes_sector?
      query = build_sector_search_query
      limit = 100
    else
      query = OpportunitySearchBuilder.new(term:              @term,
                                           boost:             @boost,
                                           sort:              @sort,
                                           sectors:           @filter.sectors,
                                           countries:         @filter.countries,
                                           opportunity_types: @filter.types,
                                           values:            @filter.values,
                                           sources:           @filter.sources).call
      query = [query[:search_query], query[:search_sort]]
      limit = @limit
    end
    query + [limit]
  end

  # Whether to run the standard search or the industries search
  def search_includes_sector?
    @filter.sectors.present?
  end
  
  # builds search_query, search_sort objects for consumption by elasticsearch
  def build_sector_search_query
    sector, sources = @filter.sectors.first, @filter.sources
    post_opps_query = {
      "bool": {
        "must": [
          {
            "match": {
              "source": 'post',
            },
          },
          {
            "match": {
              "sectors.slug": sector,
            },
          },
          {
            "match": {
              "status": 'publish',
            },
          },
          "range": {
            "response_due_on": {
              "gte": 'now/d',
            },
          },
        ],
      },
    }

    volume_opps_query = {
      "bool": {
        "must": [
          {
            "match": {
              "source": 'volume_opps',
            },
          },
          {
            "multi_match": {
              "query": sector.tr('-', ' '),
              "fields": %w[title^5 teaser^2 description],
              "operator": 'or',
            },
          },
          {
            "match": {
              "status": 'publish',
            },
          },
          "range": {
            "response_due_on": {
              "gte": 'now/d',
            },
          },
        ],
      },
    }

    search_query = if sources&.include? 'post'
                     {
                       "bool": {
                         "should": [
                           post_opps_query,
                         ],
                       },
                     }
                   elsif sources&.include? 'volume_opps'
                     {
                       "bool": {
                         "should": [
                           volume_opps_query,
                         ],
                       },
                     }
                   else
                     {
                       "bool": {
                         "should": [
                           volume_opps_query, post_opps_query
                         ],
                       },
                     }
                   end

    search_sort = [{ @sort.column.to_sym => { order: @sort.order.to_sym } }]
    [search_query, search_sort]
  end

  #
  # Searches through opportunities
  # Inputs: a query,
  #         a Sort object, 
  #         a limit (int) and a max number of documents per shard to assess
  #         returns: an elasticsearch object containing opportunities
  #
  # NOTE potential issue when using terminate_after
  # https://stackoverflow.com/questions/40423696/terminate-after-in-elasticsearch
  # "Terminate after limits the number of search hits per shard so
  # any document that may have had a hit later could also have had
  # a higher ranking(higher score) than highest ranked document returned
  # since the score used for ranking is independent of the other hits."
  #

  # 
  def perform(query, sort, limit)
    size = Figaro.env.OPPORTUNITY_ES_MAX_RESULT_WINDOW_SIZE || 100_000
    results = Opportunity.__elasticsearch__.search(size: size, 
                                                   terminate_after: limit,
                                                   query: query,
                                                   sort: sort)

    if @results_only
      page(results)
    else
      total_without_limit = Opportunity.__elasticsearch__.search(size: size, 
                                                                 query: query,
                                                                 sort: sort).count
      country_list = countries_in(results) # Run before paging.
      paged_results = page(results)
      {
        term:    @term,        
        filter:  @filter,
        sort:    @sort,
        boost:   @boost,
        results: paged_results.records,
        total:   results.records.total,
        total_without_limit: total_without_limit
        # country_list: country_list # ADD TEST Probably not needed
      }
    end
  end

  def page(results)
    results.page(@paged).per(Opportunity.default_per_page)
  end


  # Use search results to find and return
  # only which countries are relevant.
  # TODO: Refactor this low performance code.
  def countries_in(results)
    query = results.records.includes(:countries).includes(:opportunities_countries)
    countries = []
    country_list = []
    query.records.each do |opportunity|
      opportunity.countries.each do |country|
        # Array of all countries in all opportunities in result set
        countries.push(country)
      end
    end

    # in memory group by name: {"country_name": [..Country instances..]}
    countries_grouped_name = countries.group_by(&:name)
    countries_grouped_name.keys.each do |country_name|
      # set virtual attribute Country.opportunity_count
      countries_grouped_name[country_name][0].opportunity_count = countries_grouped_name[country_name].length
      country_list.push(countries_grouped_name[country_name][0])
    end

    # sort countries in list by asc name
    country_list.sort_by(&:name)
  end

end