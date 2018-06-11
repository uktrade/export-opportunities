class OpportunitySearchResultsPresenter < FormPresenter
  attr_reader :found, :form_path, :term, :selected_list, :unfiltered_search_url

  def initialize(content, search, filters)
    super(content, {})
    @search = search
    @filters = filters
    @found = search[:results]
    @view_limit = search[:limit]
    @total = search[:total]
    @sort_by = search[:sort_by]
    @term = search[:term]
    @selected_list = selected_filter_list
    @form_path = opportunities_path
  end

  # Overwriting FormPresenter.field_content to allocate for getting
  # fields and values from an unexpected location or the controller.
  def field_content(name)
    field = super(name)
    case name
    when 'industries'
      field['options'] = format_filter_options(@filters[:sectors])
      field['name'] = @filters[:sectors][:name]
    when 'regions'
      field['options'] = format_filter_options(@filters[:regions])
      field['name'] = @filters[:regions][:name]
    when 'countries'
      field['options'] = format_filter_options(@filters[:countries])
      field['name'] = @filters[:countries][:name]
    else
      {}
    end
    field
  end

  def title_with_country(opportunity)
    if opportunity.source == 'post'
      opportunity.title
    else
      country = if opportunity.countries.size > 1
                  'Multi Country'
                else
                  opportunity.countries.map(&:name).join
                end
      "#{country} - #{opportunity.title}"
    end
  end

  # Only show all if there are more than currently viewed
  # TODO: What is the view all URL?
  def view_all_link(url, css_classes = '')
    if @total > @view_limit
      link_to "View all (#{@total})", url, 'class': css_classes
    end
  end

  def displayed(css_classes = '')
    content_tag(:p, 'class': css_classes) do
      page_entries_info @found, entry_name: 'item'
    end
  end

  def found_message
    for_message = searched_for(true)
    in_message = searched_in(true)
    message = if @total > 1
                "#{@total} results found"
              elsif @total.zero?
                '0 results found'
              else
                '1 result found'
              end
    message += for_message unless for_message.empty?
    message += in_message unless in_message.empty?
    message.html_safe
  end

  # Add to 'X results found' message
  # Returns ' for [your term here]' or ''
  def searched_for(with_html = false)
    message = ''
    if @term.present?
      message = ' for '
      message += if with_html
                   content_tag('span', @term.to_s, 'class': 'param')
                 else
                   @term.to_s
                 end
    end
    message.html_safe
  end

  # TODO: Need to get 'name' rather than using 'slug' for output message
  # Add to 'X results found' message
  # Returns ' in [a country name here]' or ''
  def searched_in(with_html = false)
    message = ''
    filters = @search[:filters]
    if filters.countries.present? || filters.regions.present?
      message = ' in '
      if with_html
        selected_filter_list.each do |filter|
          message += content_tag('span', filter, 'class': 'param')
          message += ' or '
        end
      else
        message += selected_filter_list.join(' or ')
      end
    end
    message.gsub(/(\sor\s)$/, '').html_safe
  end

  def searched_in_html
    searched_in(true)
  end

  def sort_input_select
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
        { text: 'Relevance', value: 'relevance' },
      ],
    }

    input[:options].each do |option|
      option[:selected] = true if option[:value].eql? @sort_by
    end

    input
  end

  # Note: Existing filter structure is complex.
  # Actual data for each filter is an array, with
  # the first element being a symbol and the second
  # (e.g. filter[1]) being the object we want.
  def selected_filter_list
    selected = []
    @filters.each do |filter|
      next unless filter[1].key?(:selected) && filter[1][:selected].length.positive?
      filter[1][:options].each do |option|
        if filter[1][:selected].include? option[:slug]
          selected.push option[:name]
        end
      end
    end
    selected
  end

  # Pass in the query params (request.query_parameters)
  # Returns string as querystring format (?foo=bar)
  # minus the applied filters.
  def reset_url(request)
    skip_params = %w[sectors regions countries]
    path = request.original_fullpath.gsub(/^(.*?)\?.*$/, '\\1')
    keep_params = []
    request.query_parameters.each_pair do |key, value|
      unless skip_params.include? key
        if value.is_a? Array
          value.each_with_index do |val, _index|
            keep_params.push("#{key}[]=#{val}")
          end
        else
          keep_params.push("#{key}=#{value}")
        end
      end
    end
    "#{path}?#{keep_params.join('&')}"
  end

  # Format related subscription data for use in views, e.g.
  # components/subscription_form
  # components/subscription_link
  def subscription
    {
      form: @search[:subscription],
      what: searched_for,
      where: searched_in,
    }
  end

  private

  def format_filter_options(field = {})
    options = []
    field[:options].each do |option|
      label = if option[:opportunity_count].blank?
                option[:name]
              else
                "#{option[:name]} (#{option[:opportunity_count]})"
              end
      formatted_option = {
        label: label,
        value: option[:slug],
      }

      if field[:selected].include? option[:slug]
        formatted_option[:checked] = 'true'
      end

      options.push(formatted_option)
    end
    options
  end
end
