class StatsPresenter < SimpleDelegator
  include ActionView::Helpers::TextHelper
  AverageAge = Struct.new(:days, :hours)

  def average_age_when_published
    average = super
    return 'N/A' if average.nil?

    # => (seconds / secs_in_min / mins_in_hour).divmod(hours_in_day) => [days_as_int, hours_as_float]
    days_and_hours = average.divmod(24).map(&:to_i)
    average = AverageAge.new(*days_and_hours)

    parts = []
    parts << pluralize(average.days, 'day') if average.days.positive?
    parts << pluralize(average.hours, 'hour') if average.hours.positive?
    parts.join ' and '
  end

  # Outputs the average_age_when_published string in two parts,
  # and wrapped in a <span> tag, purely for display flexibility.
  def average_age_when_published_as_html(css_class = '')
    html = ''
    parts = average_age_when_published.split(' and ')
    parts.each_index do |i|
      html += if i > 0
                content_tag('span', "and #{parts[i]}")
              else
                # Trims trailing space so adding the HTML entity instead.
                content_tag('span', "#{parts[i]}&nbsp;".html_safe)
              end
    end
    content_tag('span', html.html_safe, class: css_class).html_safe
  end
end
