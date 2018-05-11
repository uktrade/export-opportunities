require 'constraints/new_domain_constraint'

class OpportunitiesController < ApplicationController
  protect_from_forgery except: :index

  def index
    # temp redirect until refactoring of poc out of namespace and into OpportunitiesController
    redirect_to '/poc'
  end

  def show
    @opportunity = Opportunity.published.find(params[:id])
    respond_to :html
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
end
