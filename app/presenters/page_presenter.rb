class PagePresenter < BasePresenter
  attr_reader :content, :breadcrumbs

  def initialize(content)
    @content = content
    @breadcrumbs = create_breadcrumbs

    add_breadcrumb_current(content['breadcrumb_current']) unless content.blank?
  end

  # Injects values into a formatted string
  #
  # e.g. Returns string "something goes here and there"
  # when
  # str = "something [$any_name] here and [$another_string]"
  # and
  # includes = ["goes", "there"]
  #
  # The identifiers any_name and another_string are irrelevant
  # and only need be used to help understand what content will
  # be injected.
  def content_with_inclusion(key, includes)
    str = @content[key] || ''
    includes.each do |include|
      str = str.sub(/\[\$.+?\]/, include)
    end
    str
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

  private

  def create_breadcrumbs
    [
      { title: 'Home', slug: 'https://www.great.gov.uk/' },
      { title: 'Export Opportunities', slug: '/' },
    ]
  end
end
