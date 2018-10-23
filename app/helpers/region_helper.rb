module RegionHelper
  # Due to the combined Region/Country single selector on
  # standard search area (e.g. landing page), we need to
  # convert passed areas[] into regions[] and countries[]
  # Note: If regions and countries exist, then search results
  # page has been viewed and those filters have already been
  # applied.
  def convert_areas_params_into_regions_and_countries(params)
    unless params[:regions] || params[:countries] || params[:areas].nil?
      params[:regions] = []
      params[:countries] = []
      params[:areas].each do |area|
        not_region = true
        regions_list.each do |region|
          next if region[:slug] != area
          params[:regions].push area
          not_region = false
          break
        end

        params[:countries].push(area) if not_region
      end
    end
    params
  end

  # Looks through a list of countries and tries to return a list of
  # region and country hashes, based on matching countries in the
  # original list to complete sets found to match a region within
  # the regions_list from RegionHelper.
  def regions_and_countries_from(countries = [])
    country_items = []
    region_items = []
    potential_regions = {}

    # First try to sort countries into potential regions.
    countries.each do |country|
      region = region_by_country(country)
      if region.present?
        region_key = region[:slug]
        unless potential_regions.key? region_key
          potential_regions[region_key] = []
        end
        potential_regions[region_key].push(country)
      else
        country_items.push(country)
      end
    end

    # Next find out how many potential region entries are complete.
    potential_regions.each_value do |country_list|
      region = region_by_countries(country_list)
      if region.present?
        region_items.push(region)
      else
        country_items.concat(country_list)
      end
    end

    # Return the (hopefully) sorted countries and regions
    { regions: region_items, countries: country_items }
  end

  # returns a human readable String representation of regions and countries from the objects
  def regions_and_countries_from_to_h(countries= [])
    regions_countries = regions_and_countries_from(countries)
    regions = regions_countries[:regions]
    countries = regions_countries[:countries]

    if regions.empty? && countries.empty?
      ""
    else
      to_h = []
      regions.each do |region|
        to_h << region[:name]
      end

      countries.each do |country|
        to_h << country[:slug].capitalize
      end

      to_h.to_sentence(last_word_connector: ' and ')
    end

  end

  # Pass in a country object to get the region containing it.
  # Return region object that matches passed country.
  # If none found, returns empty hash.
  def region_by_country(country)
    found_region = {}
    regions_list.each do |region|
      if region[:countries].include? country[:slug]
        found_region = region
        break
      end
    end
    found_region
  end

  # Return region object that matches passed name.
  # If none found, returns empty hash.
  def region_by_name(name)
    found_region = {}
    regions_list.each do |region|
      if region[:name] == name
        found_region = region
        break
      end
    end
    found_region
  end

  # Return region object that matches passed slug.
  # If none found, returns empty hash.
  def region_by_slug(slug)
    found_region = {}
    regions_list.each do |region|
      if region[:slug] == slug
        found_region = region
        break
      end
    end
    found_region
  end

  # Return region object that matches passed country list.
  # If none found, returns empty hash.
  def region_by_countries(countries)
    found_region = {}
    country_slugs = []

    # Get all the slugs...
    countries.each do |country|
      country_slugs.push(country[:slug])
    end

    # now compare slugs to those in known regions
    # (sort both for comparison)
    regions_list.each do |region|
      if region[:countries].sort == country_slugs.sort
        found_region = region
        break
      end
    end
    found_region
  end

  # TODO: Could be stored in DB but writing here.
  # DB has regions but no country ids added to any.
  # DB regions also differ slightly in names.
  # Structure is based on what we get in other filters,
  # e.g. matches structure of Sector.order(:name)
  def regions_list
    [
      { slug: 'australia_new_zealand',
        countries: %w[australia fiji new-zealand papua-new-guinea],
        name: 'Australia/New Zealand' },
      { slug: 'caribbean',
        countries: %w[barbados costa-rica cuba dominican-republic jamaica trinidad-and-tobago],
        name: 'Caribbean' },
      { slug: 'central_and_eastern_europe',
        countries: %w[bosnia-and-herzegovina bulgaria croatia czech-republic hungary macedonia poland romania serbia slovakia slovenia],
        name: 'Central and Eastern Europe' },
      { slug: 'china',
        countries: %w[china],
        name: 'China' },
      { slug: 'south_america',
        countries: %w[argentina bolivia brazil chile colombia ecuador guyana mexico panama peru uruguay venezuela],
        name: 'South America' },
      { slug: 'mediterranean_europe',
        countries: %w[cyprus greece israel italy portugal spain],
        name: 'Mediterranean Europe' },
      { slug: 'middle_east',
        countries: %w[afghanistan bahrain iran iraq jordan kuwait lebanon oman pakistan palestine qatar saudi-arabia the-united-arab-emirates],
        name: 'Middle East' },
      { slug: 'nato',
        countries: %w[nato],
        name: 'NATO' },
      { slug: 'nordic_and_baltic',
        countries: %w[denmark estonia finland iceland latvia lithuania norway sweden],
        name: 'Nordic & Baltic' },
      { slug: 'north_africa',
        countries: %w[algeria egypt libya morocco tunisia],
        name: 'North Africa' },
      { slug: 'north_america',
        countries: %w[canada the-usa],
        name: 'North America' },
      { slug: 'north_east_asia',
        countries: %w[japan japan south-korea taiwan],
        name: 'North East Asia' },
      { slug: 'south_asia',
        countries: %w[bangladesh india nepal sri-lanka],
        name: 'South Asia' },
      { slug: 'south_east_asia',
        countries: %w[brunei burma cambodia indonesia malaysia philippines singapore thailand vietnam],
        name: 'South East Asia' },
      { slug: 'sub_saharan_africa',
        countries: %w[angola cameroon ethiopia ghana ivory-coast kenya mauritius mozambique namibia nigeria rwanda senegal seychelles south-africa tanzania uganda zambia],
        name: 'Sub Saharan Africa' },
      { slug: 'turkey_russia_and_caucasus',
        countries: %w[armenia azerbaijan georgia kazakhstan mongolia russia tajikistan turkey turkmenistan ukraine uzbekistan],
        name: 'Turkey, Russia & Caucasus' },
      { slug: 'western_europe',
        countries: %w[austria belgium france germany ireland luxembourg netherlands switzerland],
        name: 'Western Europe' },
    ].sort_by { |region| region[:name] }
  end
end
