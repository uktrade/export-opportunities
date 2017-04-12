class V1::OpportunitiesController < V1::BaseController
  def show
    @result = OpportunityFinder.new.call(id)

    if @result.success?
      render :show
    else
      render_error(@result.error, @result.code)
    end
  end

  private def id
    params.require(:id)
  end
end
