class PagePresenter < BasePresenter
  include ContentHelper
  attr_reader :breadcrumbs

  def initialize(content)
    @content = content
    @breadcrumbs = create_breadcrumbs
    add_breadcrumb_current(content['breadcrumb_current']) if content.present?
  end

  def create_trade_profile_url(number = '')
    if number.blank?
      Figaro.env.TRADE_PROFILE_CREATE_WITHOUT_NUMBER
    else
      "#{Figaro.env.TRADE_PROFILE_CREATE_WITH_NUMBER}#{number}"
    end
  end

  def add_breadcrumb_current(title)
    @breadcrumbs.push(title: title, slug: '') unless title.nil?
  end

  def highlight_words(content, words)
    words.reverse_each do |word|
      content = content.gsub(Regexp.new("\\b#{word}\\b", 'i'), content_tag('span', word, class: 'highlight'))
    end
    content.html_safe
  end

  private

    def create_breadcrumbs
      [
        { title: 'Home', slug: Figaro.env.EXPORT_READINESS_URL },
        { title: 'Export Opportunities', slug: Figaro.env.EXPORT_OPPORTUNITIES_URL },
      ]
    end
end
