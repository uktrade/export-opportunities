# coding: utf-8

class OpportunitySearchResultsPresenter < FormPresenter
  include RegionHelper
  include SearchMessageHelper
  attr_reader :found, :term, :unfiltered_search_url

  #
  # Formats data from search results for the view
  #
  def initialize(content, data)
    super(content, {})
    @data = data
    @filter_data = FilterFormBuilder.new(
                     filter: @data[:filter],
                     country_list: @data[:country_list]).call
    @found = data[:results]
    @view_limit = Opportunity.default_per_page
    @total = data[:total]
    @term = data[:term]
  end

  # This extend FormPresenter.field_content to allocate when we need
  # to mix content with @filter_data from the controller.
  #
  # This method selects which component of filter_data to 
  # merge into which field
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
      {} # else do not override and use parent field_content()
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

  def found_message
    if @total > 1
      "#{@total} results found"
    elsif @total.zero?
      '0 results found'
    else
      '1 result found'
    end
  end

  # Returns results information message (with HTML)
  # We're not returning a message for empty searches or /opportunities location.
  # e.g. "X results found for [term] in [country] or [country]"
  def information
    found = @data[:total_without_limit]
    if found > @total
      found = number_with_delimiter(found, delimiter: ',')
      message = content_with_inclusion('max_results_exceeded', [@total, found])
      message += content_tag('span', content['max_results_hint'], class: 'hint')
    else
      message = found_message
      message += searched_for(@data[:term], with_html: true)
      message += searched_in(with_html: true)
    end
    message.html_safe
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
      option[:selected] = true if option[:value].eql? @data[:sort].column
    end

    input
  end

  # Returns list + HTML markup for 'Selected Filter' component.
  def selected_filter_list(title)
    id = "selected-filter-title_#{Time.now.to_i}"
    html = content_tag(:p, title, id: id)
    html += content_tag(:ul, 'aria-labelledby': id) do
      list_items = ''
      selected_filter_option_names(@data[:filter]).each do |filter|
        list_items += content_tag('span', filter, 'class': 'param')
      end
      list_items.html_safe
    end
    html.html_safe
  end

  def applied_filters?
    @data[:filter].countries.present? || @data[:filter].regions.present? || @data[:filter].sources.present?
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

  # Control whether subscription link should be shown
  def offer_subscription(not_subscription_url = true)
    f = @data[:filter]
    allowed_parameters_present = (@data[:term].present? || f.countries.present? || f.regions.present?)
    disallowed_parameters_empty = (f.sectors.blank? && f.types.blank? && f.values.blank?)
    allowed_parameters_present && disallowed_parameters_empty && not_subscription_url
  end

  # Returns hidden form fields to make sure the search results
  # form remembers original search parameters.
  def hidden_search_fields(params)
    fields = ''
    params.each do |key, value|
      key = key.to_s
      fields += hidden_field_tag 's', value, id: '' if key == 's'

      if %w[sectors].include? key
        if value.class == Array
          value.each do |item|
            fields += hidden_field_tag "#{key}[]", item, id: ''
          end
        else
          fields += hidden_field_tag "#{key}[]", value, id: ''
        end
      end
    end
    fields.html_safe
  end

  private

  # Merges @filter_data and content strings from .yml file, then
  # formats it for display
  #
  # Inputs: field:       String, e.g. 'sectors', 'countries'...
  #         filter_name: String, can be :sectors, :countries, etc...
  # Output:
  #  {
  #    name:        String - filter name e.g. 'type'
  #    question:    String - label e.g. "Type of opportunity"
  #    description: String - any description
  #    options: [   Array of hashes of format:
  #    {
  #      name:        #{name}
  #      label:       #{name} OR "#{name} (#{Opportunity Count})",
  #      description: #{description}
  #      value:       #{slug}
  #      checked:     'true' OR is blank
  #    }, ... ]
  #  }
  def format_filter_checkboxes(field, filter_name)
    filter = @filter_data[filter_name]
    field_options = prop(field, 'options')
    options = []
    filter[:options].each_with_index do |option, index|
      # Get field label content if available
      if field_options.present? && field_options.length > index
        name = prop(field_options[index], 'label')
        description = prop(field_options[index], 'description')
      else
        name = option[:name]
        description = nil
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
        description: description,
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
      description: prop(field, 'description'),
      options: options,
    }
  end

end
