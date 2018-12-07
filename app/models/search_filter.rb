class SearchFilter
  include RegionHelper
  attr_reader :sectors, :regions, :countries, :types, :values, :sources

  def initialize(params = {})
    @params = params
  end

  def sectors(datatype = nil)
    case datatype
    when :data
      sector_data
    when :name
      sector_data.pluck(:name)
    else
      sector_data.pluck(:slug)
    end
  end

  def regions(datatype = nil)
    case datatype
    when :data
      region_data
    when :name
      region_names = []
      region_data.each { |region| region_names.push(region[:name]) }
      region_names
    else
      region_slugs = []
      region_data.each { |region| region_slugs.push(region[:slug]) }
      region_slugs
    end
  end

  def countries(datatype = nil)
    case datatype
    when :data
      country_data
    when :name
      country_data.pluck(:name)
    else
      country_data.pluck(:slug)
    end
  end

  def types(datatype = nil)
    case datatype
    when :data
      type_data
    when :name
      type_data.pluck(:name)
    else
      type_data.pluck(:slug)
    end
  end

  def values(datatype = nil)
    case datatype
    when :data
      value_data
    when :name
      value_data.pluck(:name)
    else
      value_data.pluck(:slug)
    end
  end

  def sources
    # Nothing else to offer than this.
    source_data
  end

  private

  def sector_data
    @sectors ||= whitelisted_filters_for(:sectors, Sector)
  end

  def region_data
    @regions ||= whitelisted_filters_for_regions
  end

  def country_data
    @countries ||= whitelisted_filters_for(:countries, Country)
  end

  def type_data
    @types ||= whitelisted_filters_for(:types, Type)
  end

  def value_data
    @values ||= whitelisted_filters_for(:values, Value)
  end

  def source_data
    @sources ||= whitelisted_filters_for_sources
  end

  # Check requested slugs against those in DB
  def whitelisted_filters_for(name, klass)
    requested_parameters = Array(@params[name])

    return [] if requested_parameters.empty?
    klass.where(slug: requested_parameters)
  end

  # Check requested slugs against those stored in RegionHelper.regions_list
  def whitelisted_filters_for_regions
    requested_parameters = Array(@params[:regions])
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

  # Check requested values against those stored from Opportunity.sources
  def whitelisted_filters_for_sources
    requested_parameters = Array(@params[:sources])
    if requested_parameters.empty?
      []
    else
      sources = []
      requested_parameters.each { |source| sources.push(source) if Opportunity.sources.key? source }
      sources
    end
  end
end
