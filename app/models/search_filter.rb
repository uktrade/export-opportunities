class SearchFilter
  include RegionHelper
  attr_reader :params

  def initialize(params = {})
    @params = region_and_country_param_conversion(params)
    @sectors = whitelisted_filters_for(:sectors, Sector)
    @regions = whitelisted_filters_for_regions
    @countries = whitelisted_filters_for_countries
    @types = whitelisted_filters_for(:types, Type)
    @values = whitelisted_filters_for(:values, Value)
    @sources = whitelisted_filters_for_sources
    @reduced_countries = countries_not_in_selected_regions
  end

  def sectors(datatype = nil)
    return [] if @sectors.empty?
    case datatype
    when :data
      @sectors
    when :name
      @sectors.pluck(:name)
    else
      @sectors.pluck(:slug)
    end
  end

  def regions(datatype = nil)
    return [] if @regions.empty?
    case datatype
    when :data
      @regions
    when :name
      region_names = []
      @regions.each { |region| region_names.push(region[:name]) }
      region_names
    else
      region_slugs = []
      @regions.each { |region| region_slugs.push(region[:slug]) }
      region_slugs
    end
  end

  def countries(datatype = nil)
    return [] if @countries.empty?
    case datatype
    when :data
      @countries
    when :name
      @countries.pluck(:name)
    else
      @countries.pluck(:slug)
    end
  end

  def types(datatype = nil)
    case datatype
    when :data
      @types
    when :name
      @types.pluck(:name)
    else
      @types.pluck(:slug)
    end
  end

  def values(datatype = nil)
    case datatype
    when :data
      @values
    when :name
      @values.pluck(:name)
    else
      @values.pluck(:slug)
    end
  end

  def sources(datatype = nil)
    case datatype
    when :data
      @sources
    when :name
      names = []
      @sources.each { |source| names.push(source[:name]) }
      names
    else
      slugs = []
      @sources.each { |source| slugs.push(source[:slug]) }
      slugs
    end
  end

  def reduced_countries(datatype = nil)
    return [] if @reduced_countries.empty?
    case datatype
    when :data
      @reduced_countries
    when :name
      names = []
      @reduced_countries.each { |country| names.push(country[:name]) }
      names
    else
      slugs = []
      @reduced_countries.each { |country| slugs.push(country[:slug]) }
      slugs
    end
  end

  private

  # Check requested slugs against those in DB
  def whitelisted_filters_for(name, klass)
    requested_parameters = as_array(@params[name])
    if requested_parameters.empty?
      []
    else
      klass.where(slug: requested_parameters)
    end
  end

  # Check requested slugs against those stored in RegionHelper.regions_list
  def whitelisted_filters_for_regions
    requested_parameters = as_array(@params[:regions])
    if requested_parameters.empty?
      []
    else
      regions = []
      requested_parameters.each do |slug|
        region = region_by_slug(slug)
        regions.push(region) if region.present?
      end
      regions
    end
  end

  # Gets countries from both requested regions and countries params.
  def whitelisted_filters_for_countries
    country_slugs = @params[:countries] || []
    @regions.each do |region|
      country_slugs = country_slugs.concat(region[:countries])
    end
    if country_slugs.empty?
      []
    else
      Country.where(slug: country_slugs)
    end
  end

  # Check requested values against those stored from Opportunity.sources
  def whitelisted_filters_for_sources
    collection = Opportunity.sources
    requested_parameters = as_array(@params[:sources])
    if requested_parameters.empty?
      []
    else
      sources = []
      requested_parameters.each do |source|
        if collection.key? source
          source_obj = { slug: source, name: source.capitalize, value: collection[source] }
          sources.push(source_obj)
        end
      end
      sources
    end
  end

  # Because the regions are not coming from the DB, we need some special
  # handling to provide access to for countries that have been requested
  # in a search but are not in a selected/requested region as well.
  def countries_not_in_selected_regions
    country_list = []
    @countries.each do |country|
      not_in_region = true
      @regions.each do |region|
        if region[:countries].include? country[:slug]
          not_in_region = false
          break
        end
      end
      country_list.push(country) if not_in_region
    end
    country_list
  end

  def as_array(thing)
    thing.class == Array ? thing : Array(thing)
  end
end
