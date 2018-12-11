class RobotsTxtsController < ApplicationController
  def show
    if Figaro.env.DISALLOW_ALL_WEB_CRAWLERS.present?
      render 'disallow_all', layout: false, content_type: 'text/plain'
    else
      respond_to do |format|
        format.any  { head :not_found }
      end
    end
  end
end
