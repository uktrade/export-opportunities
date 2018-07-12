class SubscriptionForm
  include ActiveModel::Validations

  validate :minimum_search_criteria
  validate :countries
  validate :sectors
  validate :types
  validate :values

  def initialize(params)
    @params = params
  end

  def search_term
    query[:search_term]
  end

  def title
    query[:title]
  end

  def search_term?
    search_term.present?
  end

  def countries
    find_all_by_slug(:countries, Country)
  end

  def sectors
    find_all_by_slug(:sectors, Sector)
  end

  def types
    find_all_by_slug(:types, Type)
  end

  def values
    find_all_by_slug(:values, Value)
  end

  private def query
    @params.fetch(:query, {})
  end

  private def find_all_by_slug(name, klass)
    slugs = query[name] || []
    slugs.map { |slug| klass.find_by!(slug: slug) }
  rescue ActiveRecord::RecordNotFound
    errors.add(name, 'cannot be found')
    []
  end

  def minimum_search_criteria?
    !search_term.nil?
  end

  private def minimum_search_criteria
    unless minimum_search_criteria?
      errors[:base] << 'At least one search criteria is required, none provided.'
    end
  end

  private def filters_provided?
    sectors.any? || countries.any? || types.any? || values.any?
  end
end
