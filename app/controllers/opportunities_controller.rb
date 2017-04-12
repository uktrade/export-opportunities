require 'constraints/new_domain_constraint'

class OpportunitiesController < ApplicationController
  protect_from_forgery except: :index

  def index
    if new_domain?(request) && request.format == :html
      return redirect_to '/' if request.path == '/opportunities' && request.query_parameters.empty?
    end
    @search_term = search_term
    @filters = SearchFilter.new(params)

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

    sort_column = params[:sort]

    if sort_column
      sort_order = sort_column == 'response_due_on' ? 'asc' : 'desc'
    end

    @sort = OpportunitySort.new(default_column: 'response_due_on', default_order: 'asc')
      .update(column: sort_column, order: sort_order)

    @query = Opportunity.public_search(
      search_term: @search_term,
      filters: @filters,
      sort: @sort
    )

    @count = @query.total

    @query = @query.page(params[:paged]).per(per_page)

    if atom_request?
      @query = AtomOpportunityQueryDecorator.new(@query, view_context)
    end
    #
    @sectors = Sector.order(:name)
    @countries = Country.order(:name)
    @types = Type.order(:name)
    @values = Value.order(:name)

    @opportunities = @query
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
