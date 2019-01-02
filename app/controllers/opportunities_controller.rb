require 'constraints/new_domain_constraint'
require 'set'

class OpportunitiesController < ApplicationController
  protect_from_forgery except: :index
  include RegionHelper

  # caches_page :index

  #
  # Homepage
  # Provides the following to the views:
  #   --- html requests only --
  #   @content:              strings to insert into page
  #   @featured_industries:  Collection of Sectors
  #   @recent_opportunities: Hash of 5 recent opportunities with format
  #                             { results: opps, limit: 5, total: 5 }
  #   @countries:            Collection of Countries excluding reserved names
  #   @regions:              Array of hashes of geographic regions, of format
  #                             [{ slug: 'australia-new-zealand',
  #                                countries: ["australia", "fiji"...],
  #                                name: 'Australia/New Zealand' }, {...}...]
  #   @opportunities_stats   Hash of statistics about opportunities, of format:
  #                             { total: #, expiring_soon: #, published_recently: #, }
  #   --- .atom or .xml requests only --
  #   @query:                ElasticSearch object with Opportunity results from
  #                          query with filter params
  #   @total:                Total number of opportunities returned
  #   @opportunities:        Records from @query
  #
  def index
    respond_to do |format|
      format.html do
        @content = get_content('opportunities/index.yml')
        @recent_opportunities = recent_opportunities
        @featured_industries = featured_industries
        @countries = all_countries
        @regions = regions_list
        @opportunities_stats = opportunities_stats
        @page = LandingPresenter.new(@content, @featured_industries)
        @recent_opportunities = OpportunitySearchResultsPresenter.new(@content, @recent_opportunities)
        render layout: 'landing'
      end
      format.any(:atom, :xml) do
        query = Opportunity.public_search(
          search_term: '',
          filters: SearchFilter.new(params),
          sort: OpportunitySort.new(default_column: 'updated_at', default_order: 'desc')
        )[:search]
        query = query.records
        # return 25 results per page for atom feed
        query = query.page(params[:paged]).per(25)
        query = AtomOpportunityQueryDecorator.new(query, view_context)
        @query = query
        @total = query.records.size
        @opportunities = query.records
        render :index, formats: :atom
      end
    end
  end

  #
  # Search results listings page
  # Provides the following to the views:
  #   @content:             strings to insert into page
  #   @search_result:       Hash of data for views, of format:
  #        {
  #          filter: @search_filter,
  #          term: @search_term,
  #          sort: @sort_selection,
  #          results: results,
  #          total: total,
  #          limit: per_page,
  #          subscription: subscription_form,
  #          filter_data: {
  #            sectors: search_filter_sectors,
  #            countries: search_filter_countries(country_list),
  #            regions: search_filter_regions(country_list),
  #            sources: search_filter_sources,
  #          }
  #        }
  #   Where:
  #   @search_result[:term]:    String search term
  #   @search_result[:filter]:  Filter, contains sanitised input from filters
  #   @search_result[:sort]:    OpportunitySort, contains sanitised data from sort dropdown
  #   @search_result[:results]: ElasticSearch object with Opportunity results from
  #                             query with filter params
  #   @search_result[:total]:   Int number of results
  #   @search_result[:total_without_limit]: Int maximum number of results for search
  #   @search_result[:limit]:   Int number of results per page
  #   @search_result[:subscription]: SubscriptionForm object, receives term and arrays of
  #                             slugs for sectors, types, countries, values. Provides
  #                             each of the objects associated with the slugs. Enables
  #                             creation of the subscription form.
  #   @search_result[:filter_data]: Data to build search filters for each dimention
  #
  def results 
    term = search_term(params[:s])
    boost = params['boost_search'].present?
    filter = SearchFilter.new(params)
    sort = sorting(filter)
    
    respond_to do |format|
      format.html do
         if filter.sectors.present?
          term = filter.sectors.first.tr('-', ' ')
          search = opportunity_featured_industries_search(term, filter, sort, boost)
          query = search[:search]
          total_without_limit = search[:total_without_limit]
          country_list = relevant_countries_from_search(query) # Run before paging.
          query = query.page(filter.params[:paged]).per(Opportunity.default_per_page)
          total = query.records.total
          results = query.records
        else
          search = opportunity_search(term, filter, sort, boost)
          query = search[:search]
          total_without_limit = search[:total_without_limit]
          results = query.records
          total = query.results.total
          country_list = relevant_countries_from_search(results.includes(:countries).includes(:opportunities_countries)) # Run before paging.
          query.page(filter.params[:paged]).per(Opportunity.default_per_page)
        end
        @data = {
          term: term,
          filter: filter,
          sort: sort,
          results: results,
          total: total,
          total_without_limit: total_without_limit,
          limit: Opportunity.default_per_page,
          subscription: subscription_form(term, filter),
          filter_data: {
            sectors: filter_sectors(filter),
            countries: filter_countries(filter, country_list),
            regions: filter_regions(filter, country_list),
            sources: filter_sources(filter),
          },
        }
        content = get_content('opportunities/results.yml')
        @page = PagePresenter.new(content)
        # What is used by this presenter?
        @results = OpportunitySearchResultsPresenter.new(content, @data)
        # @page.breadcrumbs
        # @results: .information, .offer_subscription, .subscription
        #    .sort_input_select, .found, .view_all_link,
        #   .applied_filters?, .selected_filter_list,
        #   .input_checkbox_group, .none, .content
        render layout: 'results'
      end
      format.any(:atom, :xml) do
        search = opportunity_search(term, filter, sort, boost)
        query = search[:search]
        # Only uses @opportunities and @query
        query = query.records
        # return 25 results per page for atom feed
        query = query.page(params[:paged]).per(25)
        query = AtomOpportunityQueryDecorator.new(query, view_context)
        @query = query
        @total = query.records.size
        @opportunities = query.records
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

  # Builds OpportunitySort object based on filter
  private def sorting(filter)
    case filter.params[:sort_column_name]
    when 'response_due_on' # Soonest to end first
      column = 'response_due_on' and order = 'asc'
    when 'first_published_at' # Newest posted to oldest
      column = 'first_published_at' and order = 'desc' 
    when 'relevance' # Most relevant first
      column = 'response_due_on' and order = 'asc' # # TODO: Add relevance. Temporary fix
    else
      column = 'response_due_on' and order = 'asc'
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
  private def opportunity_search(term, filter, sort, boost)
    Opportunity.public_search(
      search_term: term,
      filters: filter,
      sort: sort,
      limit: 100,
      dit_boost_search: boost
    )
  end

  private def opportunity_featured_industries_search(term, filter, sort, boost)
    boost = false
    sector, sources = filter.sectors.first, filter.sources
    Opportunity.public_featured_industries_search(
              sector, term, sources, sort)
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
  # TODO: Refactor this low performance code.
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

  private def subscription_form(term, filter)
    SubscriptionForm.new(
      query: {
        search_term: term,
        sectors: filter.sectors,
        types: filter.types,
        countries: filter.countries,
        values: filter.values,
      }
    )
  end

  # Data to build search filer for sectors
  private def filter_sectors(filter)
    {
      'name': 'sectors[]',
      'options': Sector.order(:name),
      'selected': filter.sectors,
    }
  end

  # Data to build search filter for countries
  private def filter_countries(filter, country_list = [])
    countries = if country_list.present?
                  country_list
                else
                  Country.where(slug: filter.countries)
                end
    {
      'name': 'countries[]',
      'options': countries,
      'selected': filter.countries,
    }
  end

  # Data to build search filter for sources
  private def filter_sources(filter)
    {
      'name': 'sources[]',
      'options': sources_list,
      'selected': filter.sources,
    }
  end

  # Data to build search filter for regions
  private def filter_regions(filter, country_list = [])
    regions = if country_list.present?
                filtered_region_list(country_list)
              else
                regions_list
              end
    {
      'name': 'regions[]',
      'options': regions,
      'selected': filter.regions,
    }
  end

  # Filters all regions (filter[:regions]) down to
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

  def opportunities_stats
    stats = opps_counter_stats
    {
      total: stats[:total],
      expiring_soon: stats[:expiring_soon],
      published_recently: stats[:published_recently],
    }
  end
end
