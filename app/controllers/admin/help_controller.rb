class Admin::HelpController < Admin::BaseController
  rescue_from ActionView::MissingTemplate, with: :render_error_not_found
  after_action :verify_authorized, except: %i[index show article article_print]
  helper_method :sections_links

  def index
    @article_list = article_list
    render layout: 'help'
  end

  def show
    page_url = params[:article_id]
    case page_url
    when 'enquiries'
      render 'admin/enquiries/help'
    else
      render 'errors/not_found'
    end
  end

  def article
    file_path = 'admin/help/' + id_to_file(params[:article_id])
    @article = HelpArticlePresenter.new(params[:article_id], params[:section_id])
    @article_list = article_list
    render file_path, layout: 'help_article'
  end

  def article_print
    file_path = 'admin/help/' + id_to_file(params[:article_id])
    @article = HelpArticlePresenter.new(params[:article_id], params[:section_id])
    render file_path, layout: 'help_article_print'
  end

  private

    def render_error_not_found
      render 'errors/not_found'
    end

    def id_to_file(str = '')
      str = str.tr '-', '_'
      str.gsub(/[^0-9a-z] /i, '')
    end

    def article_list
      [
        { id: 'how-to-write-an-export-opportunity',
          section_id: 'overview',
          title: 'How to write an export opportunity' },
        { id: 'how-to-assess-a-company',
          title: 'How to assess a company',
          section_id: 'overview' },
        { id: 'right-for-opportunity-responses',
          title: 'How to respond to UK companies that are \'Right for opportunity\'',
          section_id: 'overview' },
        { id: 'not-right-for-opportunity-responses',
          title: 'How to respond to UK companies that are \'Not right for opportunity\'',
          section_id: 'overview' },
      ]
    end
end
