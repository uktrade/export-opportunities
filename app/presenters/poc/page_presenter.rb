class Poc::PagePresenter < BasePresenter
  attr_reader :breadcrumbs

  def initialize(title = '')
    @breadcrumbs = create_breadcrumbs
    add_breadcrumb_current(title) unless title.empty?
  end

  def add_breadcrumb_current(title)
    @breadcrumbs.push(title: title, slug: '')
  end

  private def create_breadcrumbs
    [
      { title: 'Home', slug: 'https://www.great.gov.uk/' },
      { title: 'Export Opportunities', slug: '/' },
    ]
  end
end
