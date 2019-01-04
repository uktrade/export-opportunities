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
        params.merge!({ sort_default_column: 'updated_at' })
        query = Search.new(params, results_only: true).public_search
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
  #
  def results 
    respond_to do |format|
      format.html do
        results = Search.new(params, limit: 100).run
        content = get_content('opportunities/results.yml')
        subscr_form = subscription_form(results)
        @page = PagePresenter.new(content)
        @results = OpportunitySearchResultsPresenter.new(content, results, subscr_form)
      end
      format.any(:atom, :xml) do
        results = Search.new(params, limit: 100, results_only: true).run
        @page = AtomOpportunityQueryDecorator.new(results, view_context)
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

  private 

    # Builds a subscription form
    def new_subscription_form(results)
      SubscriptionForm.new(query: {
        search_term: results[:term],
        title: 
        countries: ,
        sectors: 
        types: ,
        values: 
      })
    end

    def all_countries
      Country.all.where.not(name: ['DSO HQ', 'DIT HQ', 'NATO', 'UKREP']).order :name
    end

    def atom_request?
      request && %i[atom xml].include?(request.format.symbol)
    end

    # Get 5 most recent only
    def recent_opportunities
      today = Time.zone.today
      post_opps = Opportunity.__elasticsearch__.where(status: :publish).where('response_due_on>?', today).where(source: :post).order(first_published_at: :desc).limit(4).to_a
      volume_opps = Opportunity.__elasticsearch__.where(status: :publish).where('response_due_on>?', today).where(source: :volume_opps).order(first_published_at: :desc).limit(1).to_a

      opps = [post_opps, volume_opps].flatten

      { results: opps, limit: 5, total: 5 }
    end

    # TODO: How are the featured industries chosen?
    def featured_industries
      # Creative & Media = id(9)
      # Security = id(31)
      # Food and drink    = id(14)
      # Education & Training = id(10)
      # Oil & Gas = id(25)
      # Retail and luxury = id(30)
      Sector.where(id: Figaro.env.GREAT_FEATURED_INDUSTRIES.split(',').map(&:to_i).to_a)
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
