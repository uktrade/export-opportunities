class OpportunitySearchBuilder
  def initialize(search_term: '', sectors: [], countries: [], opportunity_types: [], values: [], expired: false, status: :published, sort:, sources: [], dit_boost_search:)
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
    keyword_query = keyword_build
    sector_query = sector_build
    country_query = country_build
    opportunity_type_query = opportunity_build
    value_query = value_build
    expired_query = expired_build
    status_query = status_build
    sort_query = sort_build
    source_query = source_build

    joined_query = [keyword_query, sector_query, country_query, opportunity_type_query, value_query, expired_query, status_query, source_query].compact

    query = {
      bool: {
        must: joined_query,
      },
    }
    sort = sort_query

    { search_query: query, search_sort: sort }
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
        }
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
end
