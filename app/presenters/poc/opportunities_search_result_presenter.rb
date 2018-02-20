class Poc::OpportunitiesSearchResultPresenter < BasePresenter
  attr_reader :items

  def initialize(helpers, opportunities, total, limit)
    @h = helpers
    @items = opportunities
    @view_limit = limit
    @total = total
  end

  # Only show all if there are more than currently viewed
  # TODO: What is the view all URL?
  def view_all_link(css_classes = '')
    if @view_limit < @total
      h.link_to "View all (#{@total})", h.poc_opportunities_path, class: css_classes
    end
  end

  private

  attr_reader :h
end
