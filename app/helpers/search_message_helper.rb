module SearchMessageHelper

  # Add to 'X results found' message
  # Returns ' for [your term here]' or ''
  def searched_for(term, with_html: false)
    message = ''
    if term.present?
      message = ' for '
      message += if with_html
                   content_tag('span', term.to_s, 'class': 'param')
                 else
                   term.to_s
                 end
    end
    message.html_safe
  end

  # Add to 'X results found' message
  # Returns ' in [a country name here]' or ''
  def searched_in(filter, with_html: false)
    selected = selected_filter_option_names(filter)
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

  # Returns list of names for selected filter options.
  def selected_filter_option_names(filter)
    region_names = filter.regions(:name).sort
    country_names = filter.reduced_countries(:name).sort
    region_names.concat(country_names)
  end

end
