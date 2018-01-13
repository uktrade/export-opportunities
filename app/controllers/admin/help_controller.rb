class Admin::HelpController < Admin::BaseController
  rescue_from ActionView::MissingTemplate, :with => :render_error_not_found
  after_action :verify_authorized, except: %i[index show article]
  helper_method :sections_links
  layout "help"

  def show
    page_url = params[:id]
    case page_url
    when 'opportunities'
      render 'admin/opportunities/help'
    when 'enquiries'
      render 'admin/enquiries/help'
    else
      render 'errors/not_found'
    end
  end

  def article
    @article = HelpArticlePresenter.new(params[:id], params[:section])
    render @article.content
  end

  def render_error_not_found
    render "errors/not_found"
  end

end
