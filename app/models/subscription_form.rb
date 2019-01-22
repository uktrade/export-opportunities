class SubscriptionForm
  include SearchMessageHelper
  include ActiveModel::Validations
  attr_accessor :params

  validate :minimum_search_criteria
  validate :countries
  validate :sectors
  validate :types
  validate :values

  #
  # Builds a subscription form object that cleans the given inputs
  # and presents for the views
  #

  def initialize(results)
    @term   = results[:term]
    @filter = results[:filter]
  end

  # Format related subscription data for use in views, e.g.
  # components/subscription_form
  # components/subscription_link
  def call
    what = searched_for(@term)
    where = searched_in(@filter)
    {
      title: (what + where).sub(/\sin\s|\sfor\s/, ''), # strip out opening ' in ' or ' for '
      keywords: @term,
      countries: @filter.countries,
      what: what,
      where: where,
    }
  end

  def search_term
    @term
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

  def minimum_search_criteria?
    @term.present? || filters_provided?
  end

  def minimum_search_criteria
    if !minimum_search_criteria?
      errors[:base] << 'At least one search criteria is required, none provided.'
    end
  end

  private

    def find_all_by_slug(name, klass)
      slugs = @filter ? (@filter.send(name) || []) : []
      slugs.map { |slug| klass.find_by!(slug: slug) }
    rescue ActiveRecord::RecordNotFound
      errors.add(name, 'cannot be found')
      []
    end

    def filters_provided?
      sectors.any? || countries.any? || types.any? || values.any?
    end
end
