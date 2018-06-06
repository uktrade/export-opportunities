require 'constraints/new_domain_constraint'
require 'set'

class OpportunitiesController < ApplicationController
  protect_from_forgery except: :index
  layout 'transformation'

  def index
    @content = get_content('opportunities/index.yml')
    @featured_industries = featured_industries
    @sort_column_name = sort_column
    @recent_opportunities = recent_opportunities
    @countries = Country.all.order :name
    @regions = regions_list
  end

  def results
    convert_areas_params_into_regions_and_countries
    @content = get_content('opportunities/results.yml')
    @filters = SearchFilter.new(params)
    @search_term = params['s']
    @sort_column_name = sort_column
    @search_results = if params[:sectors]
                        sector = params[:sectors].first
                        sector_search_term = sector.tr('-', ' ')
                        sector_obj = Sector.where(slug: sector).first

                        opportunity_featured_industries_search(sector_obj.slug, sector_search_term)
                      else
                        opportunity_search
                      end
    @total = @search_results[:total]
    @search_filters = {
      'sectors': search_filter_sectors,
      'countries': search_filter_countries(@search_results[:countries]),
      'regions': search_filter_regions,
    }
  end

  def show
    @content = get_content('opportunities/new.yml')
    @opportunity = Opportunity.published.find(params[:id])
  end

  private def search_term
    return nil unless params[:s]
    params[:s].delete("'").gsub(alphanumeric_words).to_a.join(' ')
  end

  private def alphanumeric_words
    /([a-zA-Z0-9]*\w)/
  end

  private def atom_request?
    %i[atom xml].include?(request.format.symbol)
  end

  private def new_domain?(request)
    NewDomainConstraint.new.matches? request
  end

  # Due to the combined Region/Country single selector on
  # standard search area (e.g. landing page), we need to
  # convert passed areas[] into regions[] and countries[]
  private def convert_areas_params_into_regions_and_countries
    unless params[:areas].nil?
      params[:regions] = []
      params[:countries] = []
      params[:areas].each do |area|
        regions_list.each do |region|
          if region[:slug].eql? area
            params[:regions].push area
          else
            params[:countries].push area
          end
        end
      end
      params.delete(:areas)
    end
  end

  private def sort
    # set sort_order
    if @sort_column_name
      sort_order = @sort_column_name == 'response_due_on' ? 'asc' : 'desc'
    end

    if atom_request?
      OpportunitySort.new(default_column: 'updated_at', default_order: 'desc')
    else
      OpportunitySort.new(default_column: 'response_due_on', default_order: 'asc')
        .update(column: @sort_column_name, order: sort_order)
    end
  end

  private def sort_column
    # If user is using keyword to search
    if params.key?(:isSearchAndFilter) && params[:s].present?
      'relevance'
    # If user is filtering a search
    elsif params[:sort_column_name]
      params[:sort_column_name]
    else
      'response_due_on'
    end
  end

  private def digest_search
    begin
      user_id = EncryptedParams.decrypt(params[:id])
    rescue EncryptedParams::CouldNotDecrypt
      redirect_to not_found && return
    end

    results = []
    today_date = Time.zone.now.strftime('%Y-%m-%d')

    subscription_notification_ids = SubscriptionNotification.joins(:subscription).where('subscription_notifications.created_at >= ?', today_date).where(sent: true).where('subscriptions.user_id = ?', user_id).map(&:id)
    subscription_notification_ids.each do |sub_not_id|
      results.push(SubscriptionNotification.find(sub_not_id).opportunity)
    end
  end

  # Using a search with adjusted filters that include mapped_regions.
  # Return object contains original unadjusted filters so the selected
  # country filters are not affected.
  private def opportunity_search
    country_list = []
    per_page = Opportunity.default_per_page
    query = Opportunity.public_search(
      search_term: @search_term,
      filters: filters_with_mapped_regions,
      sort: sort
    )

    if atom_request?
      query = query.records
      query = query.page(params[:paged]).per(per_page)
      query = AtomOpportunityQueryDecorator.new(query, view_context)
      results = query
    else
      country_list = relevant_countries_from_search(query) # Run before paging.
      query = query.page(params[:paged]).per(per_page)
      results = query.records
    end

    {
      filters: @filters,
      results: results,
      countries: country_list,
      total: query.records.total,
      limit: per_page,
      term: @search_term,
      sort_by: @sort_column_name,
      subscription: subscription_form,
    }
  end

  private def opportunity_featured_industries_search(sector, search_term)
    country_list = []
    per_page = Opportunity.default_per_page
    query = Opportunity.public_featured_industries_search(sector, search_term)

    if atom_request?
      query = query.records
      query = query.page(params[:paged]).per(per_page)
      query = AtomOpportunityQueryDecorator.new(query, view_context)
      results = query
    else
      country_list = relevant_countries_from_search(query) # Run before paging.
      query = query.page(params[:paged]).per(per_page)
      results = query.records
    end

    {
      filters: @filters,
      results: results,
      countries: country_list,
      total: query.records.total,
      limit: per_page,
      term: @search_term,
      sort_by: @sort_column_name,
      subscription: subscription_form,
    }
  end

  # cache expensive method call for 10 minutes
  def relevant_countries_from_search(query)
    relevant_countries_from_search!(query)
    # Rails.cache.fetch('cache/countries_from_search', expires_in: 10.minutes) do
    #   relevant_countries_from_search!(query)
    # end
  end

  # Use search results to find and return
  # only which countries are relevant.
  def relevant_countries_from_search!(query)
    countries = []
    country_list = []
    query.records.each do |opportunity|
      opportunity.countries.each do |country|
        # Array of all countries in all opportunities in result set
        countries.push(country)
      end
    end

    # in memory group by name: {"country_name": [..Country instances..]}
    countries_grouped_name = countries.group_by(&:name)
    countries_grouped_name.keys.each do |country_name|
      # set virtual attribute Country.opportunity_count
      countries_grouped_name[country_name][0].opportunity_count = countries_grouped_name[country_name].length
      country_list.push(countries_grouped_name[country_name][0])
    end

    # sort countries in list by asc name
    country_list.sort_by(&:name)
  end

  # Required workaround due to regions not coming from DB
  # For any selected region, we need to extract the associated
  # countries and add them to the countries filter, so that
  # they are included in the opportunity search.
  private def filters_with_mapped_regions
    # 1. Create new @filters (to avoid affecting original)
    # 2. For each region in regions
    # 3. Get list of countries from mapped regions
    # 4. For each country in countries
    # 5. Add country to copy_filters.countries
    # 6. Return (adjusted) copy_filters
    copy_filters = SearchFilter.new(params)
    copy_filters.regions.each do |selected_region|
      region = region_data(selected_region)
      next if region.empty?
      region[:countries].each do |country|
        copy_filters.countries.push(country) unless copy_filters.countries.include? country
      end
    end
    copy_filters
  end

  # Returns Region from static (non-DB)
  # region data in regions_list
  def region_data(slug = '')
    data = {}
    regions_list.each do |region|
      if region[:slug].eql? slug
        data = region
        break
      end
    end
    data
  end

  # Get 5 most recent only
  private def recent_opportunities
    per_page = 5
    query = Opportunity.public_search(
      search_term: nil,
      filters: SearchFilter.new,
      sort: OpportunitySort.new(default_column: 'updated_at', default_order: 'desc')
    )
    query = query.page(params[:paged]).per(per_page)
    {
      results: query.records,
      total: query.records.total,
      limit: per_page,
      sort_by: @sort_column_name,
    }
  end

  # TODO: How are the featured industries chosen?
  private def featured_industries
    # Creative & Media = id(9)
    # Security = id(31)
    # Food and drink    = id(14)
    # Education & Training = id(10)
    # Oil & Gas = id(25)
    # Retail and luxury = id(30)
    Sector.where(id: Figaro.env.GREAT_FEATURED_INDUSTRIES.split(',').map(&:to_i).to_a)
  end

  private def subscription_form
    SubscriptionForm.new(
      query: {
        search_term: @search_term,
        sectors: @filters.sectors,
        types: @filters.types,
        countries: @filters.countries,
        values: @filters.values,
      }
    )
  end

  private def search_filter_sectors
    # @filters.sectors ... lists all selected sectors
    # Sector.order(:name) ... lists all sectors in DB
    {
      'name': 'sectors[]',
      'options': Sector.order(:name),
      'selected': @filters.sectors,
    }
  end

  private def search_filter_countries(countries)
    # @filters.countries ... lists all selected countries in filters
    # search_results[:countries]... lists all countries in relevant to search
    {
      'name': 'countries[]',
      'options': countries,
      'selected': @filters.countries,
    }
  end

  private def search_filter_regions
    # @filters.regions ... lists all selected regions
    # regions_list ... lists all regionss (not stored in DB)
    {
      'name': 'regions[]',
      'options': regions_list,
      'selected': @filters.regions,
    }
  end

  # TODO: Could be stored in DB but writing here.
  # DB has regions but no country ids added to any.
  # DB regions also differ slightly in names.
  # Structure is based on what we get in other filters,
  # e.g. matches structure of Sector.order(:name)
  private def regions_list
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
    ]
  end
end
