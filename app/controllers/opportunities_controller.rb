require 'constraints/new_domain_constraint'
require 'set'

class OpportunitiesController < ApplicationController
  protect_from_forgery except: :index
  include RegionHelper

  # caches_page :index

  def index
    @content = get_content('opportunities/index.yml')
    @featured_industries = Sector.featured
    @recent_opportunities = recent_opportunities
    @countries = all_countries
    @regions = regions_list
    @opportunities_stats = opportunities_stats
    if atom_request?
      query = Opportunity.public_search(
        search_term: '',
        filters: SearchFilter.new(params),
        sort: sorting
      )
      atom_request_query(query)
    end

    respond_to do |format|
      format.html do
        render layout: 'landing'
      end
      format.js
      format.any(:atom, :xml) do
        render :index, formats: :atom
      end
    end
  end

  def results
    @search_term = search_term(params[:s])
    @dit_boost_search = params['boost_search'].present?
    @content = get_content('opportunities/results.yml')
    @search_filter = SearchFilter.new(params)
    @sort_selection = sorting
    @search_result = if @search_filter.sectors.present?
                       sector = @search_filter.sectors.first
                       sector_search_term = sector.tr('-', ' ')
                       sector_obj = Sector.where(slug: sector).first
                       sources = @search_filter.sources
                       opportunity_featured_industries_search(sector_obj.slug, sector_search_term, sources)
                     else
                       opportunity_search
                     end

    respond_to do |format|
      format.html do
        render layout: 'results'
      end
      format.js
      format.any(:atom, :xml) do
        render :index, formats: :atom
      end
    end
  end

  def show
    @content = get_content('opportunities/show.yml')
    @opportunity = Opportunity.published.find(params[:id])
    @service_provider = @opportunity.service_provider

    respond_to do |format|
      format.html do
        render layout: 'opportunity'
      end
      format.js
      format.any(:atom, :xml) do
        render :results, formats: :atom
      end
    end
  end

  private def all_countries
    Country.all.where.not(name: ['DSO HQ', 'DIT HQ', 'NATO', 'UKREP']).order :name
  end

  private def search_term(term = nil)
    term.delete("'").gsub(alphanumeric_words).to_a.join(' ') if term.present?
  end

  private def alphanumeric_words
    /([a-zA-Z0-9]*\w)/
  end

  private def atom_request?
    request && %i[atom xml].include?(request.format.symbol)
  end

  private def new_domain?(request)
    NewDomainConstraint.new.matches? request
  end

  # Builds OpportunitySort object based on params
  private def sorting
    if atom_request?
      column = 'updated_at' and order = 'desc'
    else # In-browser sort options: response_due_on, first_published_at, relevance
      case @search_filter.params[:sort_column_name]
      when 'response_due_on' # Soonest to end first
        column = 'response_due_on' and order = 'asc'
      when 'first_published_at' # Newest posted to oldest
        column = 'first_published_at' and order = 'desc' 
      when 'relevance' # Most relevant first
        column = 'response_due_on' and order = 'asc' # # TODO: Add relevance. Temporary fix
      else
        column = 'response_due_on' and order = 'asc'
      end
    end
    OpportunitySort.new(default_column: column, default_order: order)
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

  # Using a search with adjusted parameters that include mapped_regions.
  private def opportunity_search
    per_page = Opportunity.default_per_page
    query = Opportunity.public_search(
      search_term: @search_term,
      filters: @search_filter,
      sort: @sort_selection,
      limit: 100,
      dit_boost_search: @dit_boost_search
    )

    if atom_request?
      country_list = []
      atom_request_query(query)
      total = query.records.size
    else
      results = query.records
      total = query.results.total
      country_list = relevant_countries_from_search(results.includes(:countries).includes(:opportunities_countries)) # Run before paging.
      query.page(@search_filter.params[:paged]).per(per_page)
    end
    {
      filter: @search_filter,
      term: @search_term,
      sort: @sort_selection,
      results: results,
      total: total,
      limit: per_page,
      subscription: subscription_form,
      filter_data: {
        sectors: search_filter_sectors,
        countries: search_filter_countries(country_list),
        regions: search_filter_regions(country_list),
        sources: search_filter_sources,
      },
    }
  end

  private def opportunity_featured_industries_search(sector, search_term, sources)
    per_page = Opportunity.default_per_page
    query = Opportunity.public_featured_industries_search(sector, search_term, sources, @sort_selection)

    if atom_request?
      country_list = []
      query = query.records
      query = query.page(params[:paged]).per(per_page)
      query = AtomOpportunityQueryDecorator.new(query, view_context)
      total = query.records.size
      results = query
    else
      country_list = relevant_countries_from_search(query) # Run before paging.
      query = query.page(@search_filter.params[:paged]).per(per_page)
      total = query.records.total
      results = query.records
    end
    {
      filter: @search_filter,
      term: search_term,
      sort: sorting,
      results: results,
      total: total,
      limit: per_page,
      subscription: subscription_form,
      filter_data: {
        sectors: search_filter_sectors,
        countries: search_filter_countries(country_list),
        regions: search_filter_regions(country_list),
        sources: search_filter_sources,
      },
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

  # Get 5 most recent only
  private def recent_opportunities
    today = Time.zone.today
    post_opps = Opportunity.__elasticsearch__.where(status: :publish).where('response_due_on>?', today).where(source: :post).order(first_published_at: :desc).limit(4).to_a
    volume_opps = Opportunity.__elasticsearch__.where(status: :publish).where('response_due_on>?', today).where(source: :volume_opps).order(first_published_at: :desc).limit(1).to_a

    opps = [post_opps, volume_opps].flatten

    { results: opps, limit: 5, total: 5 }
  end

  private def subscription_form
    SubscriptionForm.new(
      query: {
        search_term: @search_term,
        sectors: @search_filter.sectors,
        types: @search_filter.types,
        countries: @search_filter.countries,
        values: @search_filter.values,
      }
    )
  end

  # Data to build search filer for sectors
  private def search_filter_sectors
    {
      'name': 'sectors[]',
      'options': Sector.order(:name),
      'selected': @search_filter.sectors,
    }
  end

  # Data to build search filter for countries
  private def search_filter_countries(country_list = [])
    countries = if country_list.present?
                  country_list
                else
                  Country.where(slug: @search_filter.countries)
                end
    {
      'name': 'countries[]',
      'options': countries,
      'selected': @search_filter.countries,
    }
  end

  # Data to build search filter for sources
  private def search_filter_sources
    {
      'name': 'sources[]',
      'options': sources_list,
      'selected': @search_filter.sources,
    }
  end

  # Data to build search filter for regions
  private def search_filter_regions(country_list = [])
    regions = if country_list.present?
                filtered_region_list(country_list)
              else
                regions_list
              end
    {
      'name': 'regions[]',
      'options': regions,
      'selected': @search_filter.regions,
    }
  end

  # Filters all regions (@search_filter[:regions]) down to
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

  private def sources_list
    sources = []
    disabled_sources = ['buyer']
    Opportunity.sources.keys.each do |key|
      next if disabled_sources.include? key
      sources.push(slug: key)
    end
    sources
  end

  private def atom_request_query(query)
    query = query.records
    # return 25 results per page for atom feed
    query = query.page(params[:paged]).per(25)
    query = AtomOpportunityQueryDecorator.new(query, view_context)
    @query = query
    @total = query.records.size
    @opportunities = query.records
    query
  end

  def opportunities_stats
    stats = opps_counter_stats
    {
      total: stats[:total],
      expiring_soon: stats[:expiring_soon],
      published_recently: stats[:published_recently],
    }
  end
end
