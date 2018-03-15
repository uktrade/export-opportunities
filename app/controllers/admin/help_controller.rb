class Admin::HelpController < Admin::BaseController
  rescue_from ActionView::MissingTemplate, with: :render_error_not_found
  after_action :verify_authorized, except: %i[index show article article_print]
  helper_method :sections_links

  def index
    @article_list = article_list
    render layout: 'help'
  end

  def show
    page_url = params[:id]
    case page_url
    when 'enquiries'
      render 'admin/enquiries/help'
    else
      render 'errors/not_found'
    end
  end

  def article
    article_path = 'admin/help/' + id_to_file(params[:id])
    @article = HelpArticlePresenter.new(params[:id], params[:section], article_path)
    @article_list = article_list
    render article_path, layout: 'help_article'
  end

  def render_error_not_found
    render 'errors/not_found'
  end

  def id_to_file(str = '')
    str = str.tr '-', '_'
    str.gsub(/[^0-9a-z] /i, '')
  end

  def article_print
    article_path = 'admin/help/' + id_to_file(params[:id])
    @article = HelpArticlePresenter.new(params[:id], params[:section], article_path)
    render article_path, layout: 'help_article_print'
  end

  def article_list
    [
      { id: 'how-to-write-an-export-opportunity',
        section: 'overview',
        title: 'How to write an export opportunity' },
      { id: 'how-to-assess-a-company',
        title: 'How to assess a company',
        section: 'overview' },
      { id: 'right-for-opportunity-responses',
        title: 'How to respond to UK companies that are \'Right for opportunity\'',
        section: 'overview' },
      { id: 'not-right-for-opportunity-responses',
        title: 'How to respond to UK companies that are \'Not right for opportunity\'',
        section: 'overview' },
    ]
  end
end
