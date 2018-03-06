class Poc::PagePresenter < BasePresenter
  attr_reader :breadcrumbs

  def initialize(title = '')
    @breadcrumbs = create_breadcrumbs(title)
  end

  private def create_breadcrumbs(title)
    crumbs = [
      { title: 'Home', slug: 'https://www.great.gov.uk/' },
      { title: 'Export Opportunities', slug: '/' },
    ]

    crumbs.push(title: title, slug: '') unless title.empty?
  end
end
