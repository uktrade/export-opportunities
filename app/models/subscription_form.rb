class SubscriptionForm
  include SearchMessageHelper
  include ActiveModel::Validations

  validate :minimum_search_criteria
  validate :countries
  validate :sectors
  validate :types
  validate :values

  #
  # Cleans inputs and provides wording used by the "create subscription"
  # form in the Opportunity search results view. Also provides helpers to
  # validate the form
  #
  def initialize(results)
    @term   = results[:term]
    @cpvs   = results[:cpvs]
    @filter = results[:filter].presence || NullFilter.new
  end

  # Format related subscription data for use in views, e.g.
  # components/subscription_form
  # components/subscription_link
  def data
    what = searched_for(@term)
    where = searched_in(@filter)
    {
      term: @term,
      title: (what + where).sub(/\sin\s|\sfor\s/, ''), # strip out opening ' in ' or ' for '
      cpvs: @cpvs,
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
    !@term.nil?
  end

  private

    def minimum_search_criteria
      unless minimum_search_criteria?
        errors[:base] << 'At least one search criteria is required, none provided.'
      end
    end

    def find_all_by_slug(name, klass)
      return [] unless @filter

      slugs = @filter.send(name) || []
      slugs.map { |slug| klass.find_by!(slug: slug) }.compact
    rescue ActiveRecord::RecordNotFound
      errors.add(name, 'cannot be found')
      []
    end

    def filters_provided?
      sectors.any? || countries.any? || types.any? || values.any?
    end
end
