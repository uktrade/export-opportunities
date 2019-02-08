require 'elasticsearch'

class Search
  attr_reader :term, :filter
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
  #        limit:  Int number of results to stop searching at, per shard
  #        results_only: Boolean - if true then .run only provides search results
  #                without metadata, input data, and data for filters
  #
  def initialize(params, limit: 100, results_only: false, sort: nil)
    @term   = clean_term(params[:s])
    @filter = SearchFilter.new(params)
    @sort_override = sort
    @sort   = clean_sort(params)
    @boost  = params['boost_search'].present?
    @limit  = limit
    @paged  = params[:paged]
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
      size = Figaro.env.OPPORTUNITY_ES_MAX_RESULT_WINDOW_SIZE || 100_000
      searchable[:size] = size
      Opportunity.__elasticsearch__.search(searchable)
    end

    # -- Parameter Sanitisation --

    # Cleans the term parameter
    def clean_term(term = nil)
      term.present? ? term.delete("'").gsub(alphanumeric_words).to_a.join(' ') : ''
    end

    # Regex to identify suitable words for term parameter
    def alphanumeric_words
      /([a-zA-Z0-9]*\w)/
    end

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
      if search_includes_sector?
        OpportunityIndustrySearchBuilder.new(filter: @filter,
                                             sort: @sort).call
      else
        OpportunitySearchBuilder.new(term: @term,
                                     boost: @boost,
                                     sort: @sort,
                                     limit: @limit,
                                     sectors: @filter.sectors,
                                     countries: @filter.countries,
                                     opportunity_types: @filter.types,
                                     values: @filter.values,
                                     sources: @filter.sources).call
      end
    end

    # Whether to run the standard search or the industries search
    def search_includes_sector?
      @filter.sectors.present?
    end

    # -- Helpers for formatting results --

    def page(results)
      results.records.page(@paged).per(Opportunity.default_per_page)
    end

    def get_total_without_limit(searchable)
      searchable.delete(:terminate_after)
      Opportunity.__elasticsearch__.search(searchable).count
    end

    # Use search results to find and return
    # only which countries are relevant.
    # TODO: Refactor this low performance code.
    def countries_in(results)
      query = results.records.includes(:countries).includes(:opportunities_countries)
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
end
