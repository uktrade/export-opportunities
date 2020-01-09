require 'elasticsearch'

class Search
  include ParamsHelper
  attr_reader :term, :filter, :cpvs
  #
  # Provides search functionality for Opportunities
  #
  # Input: params: url parameters Hash, with accepts keys:
  #                - s:                 search term
  #                - regions:           array of slugs of regions
  #                - countries:         array of slugs of countries
  #                - sources:           array of slugs of sources
  #                - types:             array of slugs of types
  #                - sort_column_name:  column to filter on
  #                - paged:             Which page number to return results for
  #        sort:   String, overrides params[:sort_column_name]. Options:
  #                  'response_due_on', 'first_published_at', 'updated_at'
  #        limit:  Int number of results to return
  #        results_only: Boolean - if true then .run only provides search results
  #                without metadata, input data, and data for filters
  #
  def initialize(params, limit: 500, results_only: false, sort: nil)
    @term = clean_term(params[:s])
    @cpvs = clean_cpvs(params[:cpvs])
    @filter = SearchFilter.new(params)
    @sort_override = sort
    @sort = clean_sort(params)
    @boost = params['boost_search'].present?
    @limit = limit
    @paged = params[:paged]
    @results_only = results_only
  end

  def run
    searchable = build_searchable
    results = search(searchable)
    if @results_only
      page(results)
    else
      results_and_metadata(searchable, results)
    end
  end

  private

    # Hash of results and metadata required for HTML results view
    def results_and_metadata(searchable, results)
      {
        term: @term,
        cpvs: @cpvs,
        filter: @filter,
        sort: @sort,
        boost: @boost,
        results: page(results),
        total: results.records.total,
        total_without_limit: get_total_without_limit(searchable),
        country_list: countries_in(results),
      }
    end

    def search(searchable)
      Opportunity.__elasticsearch__.search(searchable)
    end

    # -- Parameter Sanitisation --

    # Builds OpportunitySort based on filter
    def clean_sort(params)
      case @sort_override || params[:sort_column_name]
      when 'response_due_on' # Soonest to end first
        (column = 'response_due_on') && (order = 'asc')
      when 'first_published_at' # Newest posted to oldest
        (column = 'first_published_at') && (order = 'desc')
      when 'updated_at' # Most recently updated
        (column = 'updated_at') && (order = 'desc')
      when 'relevance' # Most relevant first
        (column = 'response_due_on') && (order = 'asc') # TODO: Add relevance. Temporary fix
      else
        (column = 'response_due_on') && (order = 'asc')
      end
      OpportunitySort.new(default_column: column, default_order: order)
    end

    # -- Runs the appropriate search --

    # Receives cleaned @term, @filter, @sort, @limit, @boost
    # and returns objects in Elasticsearch Syntax
    def build_searchable
      OpportunitySearchBuilder.new(term: @term,
                                   cpvs: @cpvs,
                                   boost: @boost,
                                   sort: @sort,
                                   limit: @limit,
                                   sectors: @filter.sectors,
                                   countries: @filter.countries,
                                   opportunity_types: @filter.types,
                                   values: @filter.values,
                                   sources: @filter.sources).call
    end

    # -- Helpers for formatting results --

    def page(results)
      # N.b. Kaminari pagination requires the records to be sorted again.
      results.records.order("#{@sort.column} #{@sort.order}")
        .page(@paged).per(Opportunity.default_per_page)
    end

    def get_total_without_limit(searchable)
      searchable.delete(:terminate_after)
      Opportunity.__elasticsearch__.search(searchable).count
    end

    # Use search results to find and return
    # only which countries are relevant.
    def countries_in(results)
      CountriesOpportunity.where(opportunity: results.map(&:id)).group_by(&:country_id).map do |k, v|
        if (c = Country.find(k))
          c.opportunity_count = v.length
          c
        end
      end.sort_by(&:name)
    end
end
