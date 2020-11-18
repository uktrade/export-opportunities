# frozen_string_literal: true

# SubscriptionSearchBuilder is a service object that takes collection objects
# and returns a query hash to be used on Elasticsearch to filter subscriptions
class SubscriptionSearchBuilder
  attr_reader :sectors, :countries, :types, :values

  def initialize(sectors: [], countries: [], types: [], values: [])
    @sectors   = Array(sectors)
    @countries = Array(countries)
    @types     = Array(types)
    @values    = Array(values)
  end

  def call
    base_query   = keyword_build
    filter_query = terms_build(:sectors, :countries, :types, :values)
    query        = { bool: { must: base_query } }
    filters      = {
      should: filter_query, minimum_should_match: filter_query.size / 2
    }
    query[:bool].merge!(filters) unless filter_query.empty?

    { search_query: query }
  end

  private

  def keyword_build
    [
      { match_all: {} },
      { bool: { filter: { exists: { field: :confirmed_at } } } },
      { bool: { must_not: { exists: { field: :unsubscribed_at } } } }
    ]
  end

  def terms_build(*field_names)
    field_names.flat_map do |field|
      collection = send(field)
      field_id   = "#{field}.id"
      next if collection.empty?

      [
        { terms: { "#{field_id}": collection } },
        { bool: { must_not: { exists: { field: field_id } } } }
      ]
    end.compact
  end
end
