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
end
