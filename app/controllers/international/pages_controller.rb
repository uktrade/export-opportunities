class International::PagesController < International::BaseController
  layout 'international/page'
  def index
    render 'international/index'
  end
end
