require 'constraints/new_domain_constraint' # Not used?
require 'set'

class OpportunitiesController < ApplicationController
  protect_from_forgery except: :index
  include RegionHelper

  #
  # Homepage (index)
  # Provides the following to the views:
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
  #
  def index
    @content = get_content('opportunities/index.yml')
    @recent_opportunities = recent_opportunities
    @featured_industries = Sector.featured
    @countries = all_countries
    @regions = regions_list
    @opportunities_stats = opportunities_stats
    @page = LandingPresenter.new(@content, @featured_industries)

    respond_to do |format|
      format.html do
        render layout: 'landing'
      end
    end
  end

  #
  # Search results listings page
  # Provides the following to the views:
  #   --- html requests only --
  #   @page          Presenter containing page essentials,
  #                  namely navigation breadcrumbs
  #   @results       Presenter containing the containing data associated
  #                  with search results and search/filter inputs
  #   @subscription  SubscriptionForm with sanitised data
  #   --- .atom or .xml requests only --
  #   @query         Decorator containing search results and associated
  #                  pagination and navigation helpers
  #
  def results
    respond_to do |format|
      format.html do
        content = get_content('opportunities/results.yml')
        results = Search.new(params, limit: 100).run
        @subscription = SubscriptionForm.new(results).call
        @page = PagePresenter.new(content)
        @results = OpportunitySearchResultsPresenter.new(content, results)
        render layout: 'results'
      end
      format.any(:atom, :xml) do
        results = Search.new(params, limit: 100,
                                     results_only: true,
                                     sort: 'updated_at').run
        @query = AtomOpportunityQueryDecorator.new(results, view_context)
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

    def all_countries
      Country.all.where.not(name: ['DSO HQ', 'DIT HQ', 'NATO', 'UKREP']).order :name
    end

    # 5 most recent opportunities
    def recent_opportunities
      today = Time.zone.today
      post_opps = Opportunity.__elasticsearch__.where(status: :publish).where('response_due_on>?', today).where(source: :post).order(first_published_at: :desc).limit(4).to_a
      volume_opps = Opportunity.__elasticsearch__.where(status: :publish).where('response_due_on>?', today).where(source: :volume_opps).order(first_published_at: :desc).limit(1).to_a

      [post_opps, volume_opps].flatten
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
