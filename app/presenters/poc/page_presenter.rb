class Poc::PagePresenter < BasePresenter
  attr_reader :breadcrumbs

  def initialize(content)
    @breadcrumbs = create_breadcrumbs
    add_breadcrumb_current(content['breadcrumb_current'])
  end

  private

  def add_breadcrumb_current(title)
    @breadcrumbs.push(title: title, slug: '') unless title.nil?
  end

  def create_breadcrumbs
    [
      { title: 'Home', slug: 'https://www.great.gov.uk/' },
      { title: 'Export Opportunities', slug: '/' },
    ]
  end
end
