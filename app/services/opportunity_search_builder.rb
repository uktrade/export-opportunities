class OpportunitySearchBuilder

  # Creates a pair of objects: search query and search sort, for an elastic seach
  # Inputs: ---Required---
  #         search term:       Phrase to be searched
  #         sort:              Sort object
  #         dit_boost_search:  Boolean, increases "source": 'post' posts when sorting by
  #                            relevance, will be overwritten if there is any sorting applied
  #         ---Optional---
  #         sectors:           Array of Sector slugs to filter by
  #         countries:         Array of Country slugs to filter by
  #         opportunity_types: Array of Type slugs to filter by  
  #         values:            Array of Value slugs to filter by
  #         sources:           Array of Source slugs to filter by
  #         expired:           Boolean, defaults to false, if true returns Opportunities
  #                            where response_due_on > Today
  #         status:            Symbol, if set to :published then returns Opportunities where
  #                            status='publish', defaults to  :published
  # Ouput:  call() generates Hash containing valid :search_query and :search_sort

  def initialize(search_term: '',
                 sort:,
                 sectors: [],
                 countries: [],
                 opportunity_types: [],
                 values: [],
                 sources: [],
                 expired: false,
                 status: :published,
                 dit_boost_search:)
    @search_term = search_term.to_s.strip
    @sectors = Array(sectors)
    @countries = Array(countries)
    @opportunity_types = Array(opportunity_types)
    @values = Array(values)
    @not_expired = !expired
    @status = status
    @sort = sort
    @sources = Array(sources)
    @dit_boost_search = dit_boost_search
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

    { search_query: search_query, search_sort: sort_build }
  end

  private

  def sort_build
    [{ @sort.column.to_sym => { order: @sort.order.to_sym } }]
  end

  def keyword_build
    if @search_term.empty?
      {
        match_all: {},
      }
    elsif @dit_boost_search
      {
        bool: {
          should: [
            { match: { title: { "boost": 5, "query": @search_term } } },
            { match: { teaser: { "boost": 2, "query": @search_term } } },
            { match: { description: @search_term } },
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
          query: @search_term,
          fields: ['title^5', 'teaser^2', 'description'],
          operator: 'and',
        },
      }
    end
  end

  def sector_build
    if @sectors.present?
      {
        bool: {
          should: {
            terms: {
              'sectors.slug': @sectors,
            },
          },
        },
      }
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

  def opportunity_build
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

  # Suggest adding this refactor
  # def query_builder(search_parameters, filter_type=:should)
  #   {
  #     bool: {
  #       filter: {
  #         terms: {
  #           search_parameters
  #         },
  #       },
  #     },
  #   }
  # end
end
