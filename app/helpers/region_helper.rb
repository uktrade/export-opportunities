module RegionHelper
  # Due to the combined Region/Country single selector on
  # standard search area (e.g. landing page), we need to
  # convert passed areas[] into regions[] and countries[]
  #
  # If regions and countries exist, then search results
  # page has been viewed and area conversions have already
  # been applied.
  #
  # When we have some countries, we will also try to reduce
  # the list by extracting any detected regions.
  def region_and_country_param_conversion(params)
    # Did we get here from home page search which pases areas?
    if params[:areas].present? && (params[:regions].blank? && params[:countries].blank?)
      regions = []
      countries = []
      params[:areas] = [] if params[:areas] == [''] # Default has blank entry
      params[:areas].each do |area|
        not_region = true
        regions_list.each do |region|
          next if region[:slug] != area

          regions.push area
          not_region = false
          break
        end
        countries.push(area) if not_region
      end
      params[:countries] = countries.uniq
      params[:regions] = regions.uniq
    end

    # Create region slugs if we have enough countries to make a full set.
    if params[:countries].present?
      regions = (params[:regions].presence || [])
      potential_regions = {}

      # Get potential regions by grouping countries
      params[:countries].each do |country_slug|
        region = region_by_country_slug(country_slug)
        next if region.nil?

        potential_regions[region[:slug]] = [] unless potential_regions.key? region[:slug]
        potential_regions[region[:slug]].push(country_slug)
      end

      # Do we have any full sets of countries to be a region
      potential_regions.each do |_region_name, country_slugs|
        region = region_match_country_slugs(country_slugs)
        regions.push(region[:slug]) if region.present?
      end
      params[:regions] = regions.uniq
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
  def region_and_country_names_to_h(countries = [])
    regions_countries = regions_and_countries_from(countries)

    if regions_countries[:regions].empty? && regions_countries[:countries].empty?
      ''
    else
      to_h = region_and_country_names_to_a(regions_countries)

      to_h.to_sentence(last_word_connector: ' and ')
    end
  end

  def region_and_country_names_to_a(regions_countries)
    regions = regions_countries[:regions]
    countries = regions_countries[:countries]

    result = []
    regions.each do |region|
      result << region[:name]
    end

    countries.each do |country|
      result << country[:name].capitalize
    end

    result
  end

  # Pass in a country object to get the region containing it.
  # Return region object that matches passed country.
  # Returns nil if none found.
  def region_by_country(country)
    found = nil
    regions_list.each do |region|
      if region[:countries].include? country[:slug]
        found = region
        break
      end
    end
    found
  end

  # Return region object that matches passed name.
  # Returns nil if none found.
  def region_by_name(name)
    found = nil
    regions_list.each do |region|
      if region[:name] == name
        found = region
        break
      end
    end
    found
  end

  # Return region object that matches slug.
  # Returns nil if none found.
  def region_by_slug(slug)
    found = nil
    regions_list.each do |region|
      if region[:slug] == slug
        found = region
        break
      end
    end
    found
  end

  # Return region object that matches passed country slug.
  # Returns nil if none found.
  def region_by_country_slug(country_slug)
    found = nil
    regions_list.each do |region|
      if region[:countries].include? country_slug
        found = region
        break
      end
    end
    found
  end

  # Returns a region if passed array of country slugs matches
  # a full list of countries belonging to a region.
  # Returns nil if does not match countries.
  def region_match_country_slugs(country_slugs)
    matched = nil
    regions_list.each do |region|
      next if region[:countries].sort != country_slugs.sort # sort both for comparison

      matched = region
      break
    end
    matched
  end

  # Return region object that matches passed country objects list.
  # Returns nil if none found.
  def region_by_countries(countries)
    country_slugs = []
    countries.each { |country| country_slugs.push(country[:slug]) }
    region_match_country_slugs(country_slugs)
  end

  # TODO: Could be stored in DB but writing here.
  # DB has regions but no country ids added to any.
  # DB regions also differ slightly in names.
  # Structure is based on what we get in other filters,
  # e.g. matches structure of Sector.order(:name)
  def regions_list
    [
      { slug: 'australia-new-zealand',
        countries: %w[australia fiji new-zealand papua-new-guinea],
        name: 'Australia/New Zealand' },
      { slug: 'caribbean',
        countries: %w[barbados costa-rica cuba dominican-republic jamaica trinidad-and-tobago],
        name: 'Caribbean' },
      { slug: 'central-and-eastern-europe',
        countries: %w[bosnia-and-herzegovina bulgaria croatia czech-republic hungary macedonia poland romania serbia slovakia slovenia],
        name: 'Central and Eastern Europe' },
      { slug: 'china',
        countries: %w[china],
        name: 'China' },
      { slug: 'south-america',
        countries: %w[argentina bolivia brazil chile colombia ecuador guyana mexico panama peru uruguay venezuela],
        name: 'South America' },
      { slug: 'mediterranean-europe',
        countries: %w[cyprus greece israel italy portugal spain],
        name: 'Mediterranean Europe' },
      { slug: 'middle-east',
        countries: %w[afghanistan bahrain iran iraq jordan kuwait lebanon oman pakistan palestine qatar saudi-arabia the-united-arab-emirates],
        name: 'Middle East' },
      { slug: 'nato',
        countries: %w[nato],
        name: 'NATO' },
      { slug: 'nordic-and-baltic',
        countries: %w[denmark estonia finland iceland latvia lithuania norway sweden],
        name: 'Nordic & Baltic' },
      { slug: 'north-africa',
        countries: %w[algeria egypt libya morocco tunisia],
        name: 'North Africa' },
      { slug: 'north-america',
        countries: %w[canada the-usa],
        name: 'North America' },
      { slug: 'north-east-asia',
        countries: %w[japan south-korea taiwan],
        name: 'North East Asia' },
      { slug: 'south-asia',
        countries: %w[bangladesh india nepal sri-lanka],
        name: 'South Asia' },
      { slug: 'south-east-asia',
        countries: %w[brunei burma cambodia indonesia malaysia philippines singapore thailand vietnam],
        name: 'South East Asia' },
      { slug: 'sub-saharan-africa',
        countries: %w[angola cameroon ethiopia ghana ivory-coast kenya mauritius mozambique namibia nigeria rwanda senegal seychelles south-africa tanzania uganda zambia],
        name: 'Sub Saharan Africa' },
      { slug: 'turkey-russia-and-caucasus',
        countries: %w[armenia azerbaijan georgia kazakhstan mongolia russia tajikistan turkey turkmenistan ukraine uzbekistan],
        name: 'Turkey, Russia & Caucasus' },
      { slug: 'western-europe',
        countries: %w[austria belgium france germany ireland luxembourg netherlands switzerland],
        name: 'Western Europe' },
    ].sort_by { |region| region[:name] }
  end
end
