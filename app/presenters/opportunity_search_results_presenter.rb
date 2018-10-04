# coding: utf-8

class OpportunitySearchResultsPresenter < FormPresenter
  attr_reader :found, :form_path, :term, :unfiltered_search_url

  # Arguments passed come from the opportunities_controller.rb
  # @content, @search_results, @search_filters
  def initialize(content, search, filters)
    super(content, {})
    @search = search
    @filters = filters
    @found = search[:results]
    @view_limit = search[:limit]
    @total = search[:total]
    @sort_by = search[:sort_by]
    @term = search[:term]
    @form_path = opportunities_path
  end

  # Overwriting FormPresenter.field_content to allocate when we need
  # to mix filter field content with values from the controller.
  def field_content(name)
    field = super(name)
    case name.to_s
    when 'industries'
      field = format_filter_checkboxes(field, :sectors)
    when 'regions'
      field = format_filter_checkboxes(field, :regions)
    when 'countries'
      field = format_filter_checkboxes(field, :countries)
    when 'sources'
      field = format_filter_checkboxes(field, :sources)
    else
      {}
    end
    field
  end

  # Only show all if there are more than currently viewed
  def view_all_link(url, css_classes = '')
    if @total > @view_limit
      link_to "View all (#{@total})", url, 'class': css_classes
    end
  end

  # Returns a <p> tag encased message
  def displayed(css_classes = '')
    content_tag(:p, 'class': css_classes) do
      page_entries_info @found, entry_name: 'item'
    end
  end

  def found_message(total)
    if total > 1
      "#{total} results found"
    elsif total.zero?
      '0 results found'
    else
      '1 result found'
    end
  end

  # Returns results information message (with HTML)
  # We're not returning a message for empty searches or /opportunities location.
  # e.g. "X results found for [term] in [country] or [country]"
  def information
    message = ''
    for_message = searched_for_with_html
    in_message = searched_in_with_html
    if for_message.present? || in_message.present?
      message = found_message(@total)
      message += for_message
      message += in_message
    end
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

  # Add to 'X results found' message
  # Returns ' in [a country name here]' or ''
  def searched_in(with_html = false)
    selected = selected_filters_without(@filters, [:sources])
    message = ''
    separator_in = ' in '
    list = []
    if selected.length.positive?
      separator_or = ' or '

      # If HTML is required, wrap things in tags.
      if with_html
        separator_in = content_tag('span', separator_in, 'class': 'separator')
        separator_or = content_tag('span', separator_or, 'class': 'separator')
        selected.each_index do |i|
          list.push(content_tag('span', selected[i], 'class': 'param'))
        end
      else
        list = selected
      end

      # Make it a string and remove any trailing separator_or
      message = list.join(separator_or)
      message = message.sub(Regexp.new("(.+)\s" + separator_or + "\s"), '\\1')
    end

    # Return message (if not empty, add prefix separator)
    message.sub(/^(.+)$/, separator_in + '\\1').html_safe
  end

  def searched_in_with_html
    searched_in(true)
  end

  def searched_for_with_html
    searched_for(true)
  end

  def sort_input_select
    field = content['fields']['sort']
    values = %w[response_due_on first_published_at relevance]
    options = []
    field['options'].each_with_index do |f, index|
      options.push(text: f.to_s, value: values[index])
    end
    input = {
      name: 'sort_column_name',
      id: 'search-sort',
      label: {
        id: 'search-sort',
        text: field['label'],
      },
      options: options,
    }
    input[:options].each do |option|
      option[:selected] = true if option[:value].eql? @sort_by
    end

    input
  end

  def selected_filter_list(title)
    id = "selected-filter-title_#{Time.now.to_i}"
    html = content_tag(:p, title, id: id)
    html += content_tag(:ul, 'aria-labelledby': id) do
      list_items = ''
      selected_filters(@filters).each do |filter|
        list_items += content_tag('span', filter, 'class': 'param')
      end
      list_items.html_safe
    end
    html.html_safe
  end

  def applied_filters?
    @search[:filters].countries.present? || @search[:filters] .regions.present? || @search[:filters] .sources.present?
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
    what = searched_for
    where = searched_in
    subscription = @search[:subscription]
    {
      title: (what + where).sub(/\sin\s|\sfor\s/, ''), # strip out opening ' in ' or ' for '
      keywords: subscription.search_term,
      countries: subscription.subscription_countries,
      what: what,
      where: where,
    }
  end

  # Control whether subscription link should be shown
  def offer_subscription
    f = @search[:filters]
    allowed_filters_present = (@search_term.present? || f.countries.present? || f.regions.present?)
    disallowed_filters_empty = (f.sectors.blank? && f.types.blank? && f.values.blank?)
    allowed_filters_present && disallowed_filters_empty
  end

  private

  # We have content from .yml file but want to mix data
  # from filter(s) supplied by the controller, to create
  # individual fields for use in view code.
  def format_filter_checkboxes(field, filter_name)
    filter = @filters[filter_name]
    field_options = prop(field, 'options')
    options = []
    filter[:options].each_with_index do |option, index|
      # Get field label content if available
      name = if field_options.present? && field_options.length > index
               prop(field_options[index], 'label')
             else
               option[:name]
             end

      # Some filters have a count added to the label
      label = if option[:opportunity_count].blank?
                name
              else
                "#{name} (#{option[:opportunity_count]})"
              end

      # Update initial field
      formatted_option = {
        label: label,
        name: name,
        value: option[:slug],
      }

      if filter[:selected].include? option[:slug]
        formatted_option[:checked] = 'true'
      end

      options.push(formatted_option)
    end
    {
      name: filter[:name],
      question: prop(field, 'question'),
      options: options,
    }
  end

  # Returns list of labels for selected filters.
  # Note: Existing filter structure is complex.
  # Actual data for each filter is an array, with
  # the first element being a symbol and the second
  # (e.g. filter[1]) being the object we want.
  def selected_filters(filters)
    selected = []
    filters.each do |filter|
      next unless filter[1].key?(:selected) && filter[1][:selected].length.positive?
      field = field_content(filter[0])
      prop(field, 'options').each do |option|
        next unless option[:checked]
        selected.push option[:name]
      end
    end
    selected.uniq
  end

  # Returns list of labels for selected filters after excluding some filters.
  def selected_filters_without(filters, exclusions)
    filter_list = []
    filters.each do |filter|
      next if exclusions.include? filter[0]
      filter_list.push filter
    end
    selected_filters(filter_list)
  end
end
