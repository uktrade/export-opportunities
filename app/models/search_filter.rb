class SearchFilter
  attr_reader :sectors, :regions, :countries, :types, :values, :publish_date

  def initialize(params = {})
    @params = params
  end

  def sectors
    @sectors ||= whitelisted_filters_for(:sectors, Sector)
  end

  # TODO: Not working from DB data (see opportunity_controller.rb)
  def regions
    @regions ||= (Array(@params[:regions]) || [])
  end

  def countries
    @countries ||= whitelisted_filters_for(:countries, Country)
  end

  def types
    @types ||= whitelisted_filters_for(:types, Type)
  end

  def values
    @values ||= whitelisted_filters_for(:values, Value)
  end

  def publish_date
    @publish_date ||= true
  end

  private def whitelisted_filters_for(name, klass)
    requested_parameters = Array(@params[name])

    return [] if requested_parameters.empty?

    klass.where(slug: requested_parameters).pluck(:slug)
  end
end
