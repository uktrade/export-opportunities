class OpportunityIndustrySearchBuilder
  def initialize(filter: NullFilter.new,
    sort: OpportunitySort.new(default_column: 'first_published_at',
                              default_order: 'asc'))
    @filter = filter
    @sort = sort
  end

  # builds search_query, search_sort objects for consumption by elasticsearch
  def call
    sector = @filter.sectors.first
    sources = @filter.sources
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

    {
      query: search_query,
      sort: search_sort,
      terminate_after: 100,
    }
  end
end
