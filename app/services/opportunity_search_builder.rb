class OpportunitySearchBuilder
  def initialize(search_term: '', sectors: [], countries: [], opportunity_types: [], values: [], expired: false, status: :published, source: [:post, :volume_opps], sort:)
    @search_term = search_term.to_s.strip
    @sectors = Array(sectors)
    @countries = Array(countries)
    @opportunity_types = Array(opportunity_types)
    @values = Array(values)
    @not_expired = !expired
    @status = status
    @sort = sort
    @source = source
  end

  def call
    keyword_query = keyword_build
    sector_query = sector_build
    country_query = country_build
    opportunity_type_query = opportunity_build
    value_query = value_build
    expired_query = expired_build
    status_query = status_build
    source_query = source_build
    sort_query = sort_build

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

  def source_build
    if @source.present?
      {
          bool: {
              filter: {
                  terms: {
                      source: @source,
                  },
              },
          },
      }
    end
  end
end
