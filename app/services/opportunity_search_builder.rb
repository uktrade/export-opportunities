class OpportunitySearchBuilder
  # Creates a pair of objects: search query and search sort, for an elastic seach
  # Inputs: ---Optional---
  #         term:       Phrase to be searched
  #         sectors:           Array of Sector slugs to filter by
  #         sort:              Sort object
  #         boost:             Boolean, increases "source": 'post' posts when sorting by
  #                            relevance, will be overwritten if there is any sorting applied
  #         countries:         Array of Country slugs to filter by
  #         opportunity_types: Array of Type slugs to filter by
  #         values:            Array of Value slugs to filter by
  #         sources:           Array of Sources slugs to filter by
  #         expired:           Boolean, defaults to false, if true also returns expired
  #                            Opportunities (where response_due_on < Today)
  #         status:            Symbol, if set to :published then only returns Opportunities
  #                            where status='publish', otherwise returns all.
  #                            Defaults to :published
  # Ouput:  call() generates Hash containing valid :query, :sort and :terminate_after params
  #         digestable by Opportunity.__elasticsearch__.search()

  def initialize(term: '',
    sort: OpportunitySort.new(default_column: 'first_published_at',
                              default_order: 'asc'),
    limit: 100,
    sectors: [],
    countries: [],
    opportunity_types: [],
    values: [],
    sources: [],
    expired: false,
    status: :published,
    boost: false)
    @term = term.to_s.strip
    @limit = limit
    @sectors = Array(sectors)
    @countries = Array(countries)
    @opportunity_types = Array(opportunity_types)
    @values = Array(values)
    @not_expired = !expired
    @status = status
    @sort = sort
    @sources = Array(sources)
    @boost = boost
  end

  def call
    joined_query = [keyword_build,
                    sector_build,
                    country_build,
                    opportunity_type_build,
                    value_build,
                    expired_build,
                    status_build,
                    source_build].compact

    search_query = {
      bool: {
        must: joined_query,
      },
    }

    {
      query: search_query,
      sort: sort_build,
      terminate_after: @limit,
    }
  end

  private

    def sort_build
      [{ @sort.column.to_sym => { order: @sort.order.to_sym } }]
    end

    def keyword_build
      if @term.empty?
        {
          match_all: {},
        }
      elsif @boost
        {
          bool: {
            should: [
              { match: { title: { "boost": 5, "query": @term } } },
              { match: { teaser: { "boost": 2, "query": @term } } },
              { match: { description: @term } },
              {
                "boosting": {
                  "positive": {
                    "term": {
                      "source": 'post',
                    },
                  },
                  "negative": {
                    "term": {
                      "source": 'volume_opps',
                    },
                  },
                  "negative_boost": 0.1,
                },
              },
            ],
            minimum_should_match: 2,
          },
        }
      else
        {
          multi_match: {
            query: @term,
            fields: ['title^5', 'teaser^2', 'description'],
            operator: 'and',
          },
        }
      end
    end

    def sector_build
      if @sectors.present?
        post_opps_query = {
          "bool": {
            "must": [
              {
                "term": {
                  "source": 'post',
                },
              },
              {
                "terms": {
                  "sectors.slug": @sectors,
                },
              },
              {
                "term": {
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
                "term": {
                  "source": 'volume_opps',
                },
              },
              {
                "multi_match": {
                  "query": @sectors.join(" ").tr('-', ' '),
                  "fields": %w[title^5 teaser^2 description],
                  "operator": 'or',
                },
              },
              {
                "term": {
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

        if @sources&.include? 'post'
          {
            "bool": {
              "should": [
                post_opps_query,
              ],
            },
          }
        elsif @sources&.include? 'volume_opps'
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
      end
    end

    def country_build
      if @countries.present?
        {
          bool: {
            should: {
              terms: {
                'countries.slug': @countries,
              },
            },
          },
        }
      end
    end

    def opportunity_type_build
      if @opportunity_types.present?
        {
          bool: {
            should: {
              terms: {
                'types.slug': @opportunity_types,
              },
            },
          },
        }
      end
    end

    def value_build
      if @values.present?
        {
          bool: {
            should: {
              terms: {
                'values.slug': @values,
              },
            },
          },
        }
      end
    end

    def source_build
      if @sources.present?
        {
          bool: {
            should: {
              terms: {
                'source': @sources,
              },
            },
          },
        }
      end
    end

    def expired_build
      if @not_expired
        {
          range: {
            'response_due_on': {
              'gte': 'now/d',
            },
          },
        }
      end
    end

    def status_build
      if @status == :published
        {
          bool: {
            filter: {
              terms: {
                status: ['publish'],
              },
            },
          },
        }
      end
    end
end
