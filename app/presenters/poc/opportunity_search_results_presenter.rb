class Poc::OpportunitySearchResultsPresenter < Poc::FormPresenter
  attr_reader :found, :form_path, :term

  def initialize(helpers, content, search)
    @h = helpers
    super(content, {})
    @found = search[:results]
    @view_limit = search[:limit]
    @term = search[:term]
    @total = search[:total]
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

  def found_message_html
    if @total.size > 1
      message = "#{@total.size} results found"
    else
      message = "#{@total.size} result found"
    end
    
    unless @term.nil?
      message += " for "
      message += content_tag("span", "#{@term}", :class=>"param")
    end
    message.html_safe
  end

  def found_message(with_html=false)
    if @total.size > 1
      message = "#{@total.size} results found"
    else
      message = "#{@total.size} result found"
    end
    message += searched_for(with_html)
    message.html_safe
  end

  def searched_for(with_html=false)
    message = ''
    unless @term.nil?
      message += " for "
      if with_html
        message += content_tag("span", "#{@term}", :class=>"param")
      else
        message += "#{@term}"
      end
    end
    message.html_safe
  end

  private

  attr_reader :h
end
