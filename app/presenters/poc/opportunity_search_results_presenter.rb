class Poc::OpportunitySearchResultsPresenter < Poc::FormPresenter
  attr_reader :found, :form_path, :term

  def initialize(helpers, content, search)
    @h = helpers
    super(content, {})
    @found = search[:results]
    @view_limit = search[:limit]
    @term = search[:term]
    @total = search[:total]
    @sort_by = search[:sort_by]
    @form_path = poc_opportunities_path
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
      link_to "View all (#{@total})", poc_opportunities_path, 'class': css_classes
    end
  end

  def displayed(css_classes = '')
    content_tag(:p, 'class': css_classes) do
      page_entries_info @found, entry_name: 'item'
    end
  end

  def navigation(css_classes = '')
    content_tag(:div, 'class': css_classes) do
      h.paginate @found, views_prefix: 'poc/components'
    end
  end

  def found_message
    message = if @found.size > 1
                "#{@found.size} results found"
              elsif @found.size < 1
                "0 results found"
              else
                "1 result found"
              end
    message += searched_for(true)
    message.html_safe
  end

  def searched_for(with_html = false)
    message = ''
    unless @term.nil?
      message += ' for '
      message += if with_html
                   content_tag('span', @term.to_s, 'class': 'param')
                 else
                   @term.to_s
                 end
    end
    message.html_safe
  end

  def sort_input_select
    # options = input_select('sort')
    input = {
      name: 'sort_column_name',
      id: 'search-sort',
      label: {
        id: 'search-sort',
        text: 'Sort by',
      },
      options: [
        { text: 'Expiry date', value: 'response_due_on' },
        { text: 'Published date', value: 'first_published_at' },
        { text: 'Relevance', value: 'relevance' }
      ]
    }

    input[:options].each do |option|
      if option[:value].eql? @sort_by
        option[:selected] = true
      end
    end

    input
  end

  private

  attr_reader :h
end
