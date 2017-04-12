class CompanyDetailsController < ApplicationController
  def index
    @results = if search_query
                 CompanyHouseFinder.new.call(search_query)
               else
                 []
               end

    render json: @results.to_json
  end

  def search_query
    params.require(:search)
  rescue ActionController::ParameterMissing
    false
  end
end
