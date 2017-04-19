class SubscriptionSearchBuilder
  def initialize(search_term: '', sectors: [], countries: [], opportunity_types: [], values: [], confirmed_at: nil, unsubscribed_at: nil)
    @search_term = search_term.to_s.strip
    @sectors = Array(sectors)
    @countries = Array(countries)
    @opportunity_types = Array(opportunity_types)
    @values = Array(values)
    @confirmed_at = confirmed_at
    @unsubscribed_at = unsubscribed_at
  end

  def call
    keyword_query = keyword_build
    sector_query = sector_build
    country_query = country_build
    opportunity_type_query = opportunity_build
    value_query = value_build
    confirmed_at_query = confirmed_at_build
    unsubscribed_at_query = unsubscribed_at_build

    mandatory_fields = [keyword_query, confirmed_at_query, unsubscribed_at_query].compact
    taxonomy_filters = [sector_query, country_query, opportunity_type_query, value_query].compact

    query = if taxonomy_filters.empty? || taxonomy_filters.size == 4
              {
                bool: {
                  must: mandatory_fields,
                },
              }
            else
              {
                bool: {
                  must: mandatory_fields,
                  should: taxonomy_filters,
                  minimum_should_match: 1,
                },
              }
            end

    { search_query: query }
  end

  private

  def keyword_build
    if @search_term.empty?
      {
        match_all: {},
      }
    else
      {
        multi_match: {
          query: @search_term,
          fields: ['search_term'],
          operator: 'and',
        },
      }
    end
  end

  def sector_build
    if @sectors.present?
      {
        terms: {
          'sectors.id': @sectors,
        },
      }
    end
  end

  def country_build
    if @countries.present?
      {
        terms: {
          'countries.id': @countries,
        },
      }
    end
  end

  def opportunity_build
    if @opportunity_types.present?
      {
        terms: {
          'types.id': @opportunity_types,
        },
      }
    end
  end

  def value_build
    if @values.present?
      {
        terms: {
          'values.id': @values,
        },
      }
    end
  end

  def confirmed_at_build
    {
      bool: {
        filter: {
          exists: {
            field: :confirmed_at,
          },
        },
      },
    }
  end

  def unsubscribed_at_build
    {
      bool: {
        must_not: {
          exists: {
            field: :unsubscribed_at,
          },
        },
      },
    }
  end
end

# {
# "query": {
#     "bool": {
#         "must": [
#             {
#                 "match": {
#                     "search_term": "test"
#                 }
#             }
#         ],
#         "filter": [
#             {
#                 "term": {
#                     "types.id": "1"
#                 }
#             },
#             {
#                 "term": {
#                     "sectors.id": "1"
#                 }
#             }
#         ]
#     }
# }
# }
