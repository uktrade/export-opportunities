class RobotsTxtsController < ApplicationController
  def show
    if Figaro.env.DISALLOW_ALL_WEB_CRAWLERS.present?
      render 'disallow_all', layout: false, content_type: 'text/plain'
    else
      render nothing: true, status: 404
    end
  end
end
