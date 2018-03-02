class Poc::OpportunitiesSearchResultPresenter < BasePresenter
  attr_reader :results

  def initialize(helpers, opportunities, total, limit)
    @h = helpers
    @results = opportunities
    @view_limit = limit
    @total = total
  end

  # Only show all if there are more than currently viewed
  # TODO: What is the view all URL?
  def view_all_link(css_classes = '')
    if @total > @view_limit
      h.link_to "View all (#{@total})", h.poc_opportunities_path, 'class': css_classes
    end
  end

  def message(css_classes = '')
    h.content_tag(:p, 'class': css_classes) do
      h.page_entries_info @results, entry_name: 'item'
    end
  end

  def navigation(css_classes = '')
    h.content_tag(:div, 'class': css_classes) do
      h.paginate @results, views_prefix: 'poc/components'
    end
  end

  private

  attr_reader :h
end
