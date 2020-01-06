class SubscriptionSearchBuilder
  def initialize(search_term: '', cpvs: [], sectors: [], countries: [], opportunity_types: [], values: [], confirmed_at: nil, unsubscribed_at: nil)
    @search_term = search_term.to_s.strip
    @cpvs = cpvs.any? ? cpvs.map(&:industry_id) : []
    @sectors = Array(sectors)
    @countries = Array(countries)
    @opportunity_types = Array(opportunity_types)
    @values = Array(values)
    @confirmed_at = confirmed_at
    @unsubscribed_at = unsubscribed_at
  end

  def call
    mandatory_fields = [keyword_build, cpvs_build, confirmed_at_build, unsubscribed_at_build].compact
    taxonomy_filters = [sector_build, country_build, opportunity_build, value_build].compact

    query = if taxonomy_filters.empty?
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
                  minimum_should_match: taxonomy_filters.size,
                },
              }
            end

    { search_query: query }
  end

  private

    def keyword_build
      {
        match_all: {},
      }
    end

    def cpvs_build
      if @cpvs.present?
        a = {
          bool: {
            should: {
              query_string: {
                query: @cpvs.map{|cpv| "#{cpv}*" }.join(' '),
                fields: ['cpvs.industry_id']
              }
            },
          },
        }
        a
      end
    end

    def sector_build
      if @sectors.present?
        [
          {
            terms: {
              'sectors.id': @sectors,
            },
          },
          {
            bool: {
              must_not: {
                exists: {
                  field: 'sectors.id',
                },
              },
            },
          },
        ].compact
      end
    end

    def country_build
      if @countries.present?
        [
          {
            terms: {
              'countries.id': @countries,
            },
          },
          {
            bool: {
              must_not: {
                exists: {
                  field: 'countries.id',
                },
              },
            },
          },
        ].compact
      end
    end

    def opportunity_build
      if @opportunity_types.present?
        [
          {
            terms: {
              'types.id': @opportunity_types,
            },
          },
          {
            bool: {
              must_not: {
                exists: {
                  field: 'types.id',
                },
              },
            },
          },
        ].compact
      end
    end

    def value_build
      if @values.present?
        [
          {
            terms: {
              'values.id': @values,
            },
          },
          {
            bool: {
              must_not: {
                exists: {
                  field: 'values.id',
                },
              },
            },
          },
        ].compact
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
