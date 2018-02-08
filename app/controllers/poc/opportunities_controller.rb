class Poc::OpportunitiesController < OpportunitiesController
  prepend_view_path 'app/views/poc'

  def index
    render "opportunities/index"
  end

  def international
    render "opportunities/international", layout: "layouts/landing_international"
  end
end
