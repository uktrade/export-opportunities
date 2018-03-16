class Poc::OpportunitiesSearchResultsPresenter < BasePresenter
  attr_reader :found

  def initialize(helpers, opportunities, total, limit)
    @h = helpers
    @found = opportunities
    @view_limit = limit
    @total = total
  end

  def title_with_country(opportunity)
    country = if opportunity.countries.size > 1
                'Multi Country'
              else
                opportunity.countries.map(&:name).join
              end
    "#{country} - #{opportunity.title}"
  end

  # Only show all if there are more than currently viewed
  # TODO: What is the view all URL?
  def view_all_link(css_classes = '')
    if @total > @view_limit
      h.link_to "View all (#{@total})", h.poc_opportunities_path, 'class': css_classes
    end
  end

  def displayed(css_classes = '')
    h.content_tag(:p, 'class': css_classes) do
      h.page_entries_info @found, entry_name: 'item'
    end
  end

  def navigation(css_classes = '')
    h.content_tag(:div, 'class': css_classes) do
      h.paginate @found, views_prefix: 'poc/components'
    end
  end

  private

  attr_reader :h
end
