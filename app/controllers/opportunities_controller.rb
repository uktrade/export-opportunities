require 'constraints/new_domain_constraint'

class OpportunitiesController < ApplicationController
  protect_from_forgery except: :index

  def index
    if new_domain?(request) && request.format == :html
      return redirect_to '/' if request.path == '/opportunities' && request.query_parameters.empty?
    end
    @search_term = search_term
    @filters = SearchFilter.new(params)
    pp @filters.countries

    @subscription_form = SubscriptionForm.new(
      query: {
        search_term: @search_term,
        sectors: @filters.sectors,
        types: @filters.types,
        countries: @filters.countries,
        values: @filters.values,
      }
    )

    @description = SubscriptionPresenter.new(@subscription_form).description

    per_page = if atom_request?
                 25
               else
                 Opportunity.default_per_page
               end

    sort_column = params.fetch(:sort_column, 'response_due_on')

    Rails.logger.debug "sort_column: #{sort_column}"

    if sort_column
      sort_order = sort_column == 'response_due_on' ? 'asc' : 'desc'
    end

    if atom_request?
      @sort = OpportunitySort.new(default_column: 'updated_at', default_order: 'desc')
    else
      @sort = OpportunitySort.new(default_column: 'response_due_on', default_order: 'asc')
        .update(column: sort_column, order: sort_order)
    end

    @query = Opportunity.public_search(
      search_term: @search_term,
      filters: @filters,
      sort: @sort
    )

    if atom_request?
      @query = @query.records
      @query = @query.page(params[:paged]).per(per_page)
      @query = AtomOpportunityQueryDecorator.new(@query, view_context)
      @opportunities = @query
    else
      @count = @query.records.total
      @query = @query.page(params[:paged]).per(per_page)

      @opportunities = @query.records
    end

    @sectors = Sector.order(:name)
    @countries = Country.order(:name)
    @types = Type.order(:name)
    @values = Value.order(:name)

    @suppress_subscription_block = params[:suppress_subscription_block].present?

    respond_to do |format|
      format.html
      format.js
      format.any(:atom, :xml) do
        render :index, formats: :atom
      end
    end
  end

  def show
    @opportunity = Opportunity.published.find(params[:id])
    respond_to :html
  end

  private def search_term
    return nil unless params[:s]
    params[:s].gsub(alphanumeric_words).to_a.join(' ')
  end

  private def alphanumeric_words
    /([a-zA-Z0-9]*\w)/
  end

  private def atom_request?
    %i(atom xml).include?(request.format.symbol)
  end

  private def new_domain?(request)
    NewDomainConstraint.new.matches? request
  end
end
