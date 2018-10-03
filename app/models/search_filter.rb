class SearchFilter
  attr_reader :sectors, :regions, :countries, :types, :values, :sources

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

  def sources
    param_sources = Array(@params[:sources])
    sources = []
    # make sure we only allow valid entries.
    param_sources.each do |source|
      next unless Opportunity.sources.key? source
      sources.push source
    end
    @sources = sources
  end

  private def whitelisted_filters_for(name, klass)
    requested_parameters = Array(@params[name])

    return [] if requested_parameters.empty?

    klass.where(slug: requested_parameters).pluck(:slug)
  end
end
