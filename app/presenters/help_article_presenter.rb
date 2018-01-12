class HelpArticlePresenter < BasePresenter

  def initialize(article_path="")
    @article_path = article_path
  end

  def section(title="")
    section_url = "%s/%s" % [@article_path, text_to_id(title)] 
    view_context = ActionView::Base.new
    view_context.link_to title, section_url
  end

  def text_to_id(str="")
    str = str.gsub(" ", "-")
    str = str.gsub(/[^0-9a-z-]/i, '')
    str.downcase
  end

end
