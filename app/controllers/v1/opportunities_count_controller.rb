class V1::OpportunitiesCountController < V1::BaseController
  def show
    opportunities_count = Opportunity.published.applicable.count

    render json: { 'opportunities_count' => opportunities_count }
  end
end
