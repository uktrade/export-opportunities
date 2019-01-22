class FilterFormBuilder

  # creates object for use by the country and region inputs
  def initialise(filter, country_list)
    @filter = filter
    @country_list = country_list
  end

  def call
    return nil unless @filter.present? 
    {
      sectors: filter_sectors,
      countries: filter_countries,
      regions: filter_regions,
      sources: filter_sources,
    }
  end

  private

    # Data to build search filter input for sectors
    def filter_sectors
      {
        'name': 'sectors[]',
        'options': Sector.order(:name),
        'selected': filter.sectors,
      }
    end

    # Data to build search filter input for countries
    def filter_countries
      {
        'name': 'countries[]',
        'options': @country_list || Country.where(slug: filter.countries),
        'selected': filter.countries,
      }
    end

    # Data to build search filter input for regions
    def filter_regions
      regions = if @country_list.present?
                  filtered_region_list(@country_list)
                else
                  regions_list
                end
      {
        'name': 'regions[]',
        'options': regions,
        'selected': filter.regions,
      }
    end

    # Data to build search filter input for sources
    def filter_sources
      {
        'name': 'sources[]',
        'options': sources_list,
        'selected': filter.sources,
      }
    end

    # Filters all regions (@filter[:regions]) down to
    # return only those that are applicable to countries
    # showing (so those that apply to the search)
    def filtered_region_list(countries)
      regions = []
      countries.each do |country|
        region = region_by_country(country)
        regions.push(region) if region.present?
      end
      regions.uniq
    end

    def sources_list
      sources = []
      disabled_sources = ['buyer']
      Opportunity.sources.keys.each do |key|
        next if disabled_sources.include? key
        sources.push(slug: key)
      end
      sources
    end
end
