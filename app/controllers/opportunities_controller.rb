require 'constraints/new_domain_constraint' # Not used?
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
        query = Search.new({
          term: '',
          filter: SearchFilter.new(params),
          sort: OpportunitySort.new(default_column: 'updated_at', default_order: 'desc')
        }).public_search[:search]
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
  # --- HTML only ---
  # @page:    PagePresenter
  # @results: OpportunitySearchResultsPresenter
  # --- Atom only ---
  # @query:   results andmetadata about results
  #
  def results 
    # Clean params
    filter = SearchFilter.new(params)
    inputs = { term: search_term(params[:s]),        
               filter: filter,
               sort: sorting(filter),
               boost: params['boost_search'].present? }
    
    respond_to do |format|
      format.html do

        if industry_search?(filter)
          inputs[:term] = filter.sectors.first.tr('-', ' ')
          result = Search.new(inputs).industries_search
        else
          result = Search.new(inputs, limit: 100).public_search
        end

        results = result[:search]
        country_list = countries_in(results) # Run before paging.
        paged_results = page(results, filter.params[:paged])

        data = {
          results: paged_results.records,
          total: results.records.total,
          total_without_limit: search[:total_without_limit],
          subscription: subscription_form(inputs),
          country_list: country_list # ADD TEST
        }.merge(inputs)
        content = get_content('opportunities/results.yml')

        @page = PagePresenter.new(content)
        @results = OpportunitySearchResultsPresenter.new(content, data)
        render layout: 'results'
      end
      format.any(:atom, :xml) do
        results = Search.new(inputs, limit: 100).public_search
        paged_results = page(results, params[:paged])
        
        @query = AtomOpportunityQueryDecorator.new(paged_results, view_context)
        
        render :index, formats: :atom
      end
    end
  end


        # search = Search.new(inputs, limit: 100).public_search
        # query = search[:search]
        # # Only uses @opportunities and @query
        # query = query.records
        # # return 25 results per page for atom feed
        # query = query.page(params[:paged]).per(25)
        # query = AtomOpportunityQueryDecorator.new(query, view_context)
        # @query = query
        # @total = query.records.size
        # @opportunities = query.records
        # render :index, formats: :atom

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

  private def industries_search?(filter)
    filter.sectors.present?
  end

  private def countries_in(results)
    relevant_countries_from_search(results.records.includes(:countries).includes(:opportunities_countries))
  end

  private def page(results, filter)
    page.page(filter.params[:paged]).per(Opportunity.default_per_page)
  end


  # Use search results to find and return
  # only which countries are relevant.
  # TODO: Refactor this low performance code.
  def relevant_countries_from_search(query)
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

  private def subscription_form(inputs)
    filter = inputs[:filter]
    SubscriptionForm.new(
      query: {
        search_term: inputs[:term],
        sectors: filter.sectors,
        types: filter.types,
        countries: filter.countries,
        values: filter.values,
      }
    )
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
