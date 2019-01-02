require 'elasticsearch'

class Search
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

  def initialize(inputs, limit: 100)
    @term   = inputs[:term]   || ''
    @filter = inputs[:filter] || NullFilter.new()
    @sort   = inputs[:sort]   || 
                OpportunitySort.new(default_column: 'first_published_at',
                                    default_order: 'desc')
    @boost  = inputs[:boost]  || false 
    @limit = limit
  end

  # Beginnings of generic solution
  # def call
  #   search = public_search
  #   @results = search[:search]
  #   @total = @results.size
  #   @total_without_limit = search[:total_without_limit]
  #   self
  # end

  # 
  # Returns Opportunities search results given a set of parameters
  # Inputs: --- Optional ---
  #         term:             the search term, defaults to nil
  #         filters:          Filter, defaults to blank
  #         sort:             Sort object; sort column and direction
  #         limit:            Int, max number of documents to search, per shard.
  #                           Defaults to zero causing no search to occur
  #         
  #         boost: Boolean, makes the search
  #                           prioritise DIT-sourced results
  # Returns: an ElasticSearch search results object
  #
  def public_search
    query = OpportunitySearchBuilder.new(term:              @term,
                                         boost:             @boost,
                                         sort:              @sort,
                                         sectors:           @filter.sectors,
                                         countries:         @filter.countries,
                                         opportunity_types: @filter.types,
                                         values:            @filter.values,
                                         sources:           @filter.sources).call

    perform(query[:search_query], query[:search_sort], @limit)
  end
  
  # 
  # Given a set of parameters,
  # returns Opportunities search results
  # Note: needs a term and filter.sectors to function correctly
  #       (this was due to previous way it was built / implemented)
  #
  def industries_search
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
              "query": @term,
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

    perform(search_query, search_sort, 100)
  end

  private

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
    def perform(query, sort, limit)
      size = Figaro.env.OPPORTUNITY_ES_MAX_RESULT_WINDOW_SIZE || 100_000
      total_without_limit = Opportunity.__elasticsearch__.search(size: size, 
                                                                 query: query,
                                                                 sort: sort).count
      search = Opportunity.__elasticsearch__.search(size: size, 
                                                    terminate_after: limit,
                                                    query: query,
                                                    sort: sort)
      { search: search, total_without_limit: total_without_limit }
    end

end