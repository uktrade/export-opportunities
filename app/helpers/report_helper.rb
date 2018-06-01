module ReportHelper
  def cen_network?(country_id)
    # [82, 105, 65, 69, 96,162, 174, 23, 21, 165, 142, 115, 147, 119, 160].include? country_id
    [13, 16, 25, 28, 45, 64, 83, 86, 90, 94, 95].include? country_id
  end

  def nbn_network?(country_id)
    # [34, 77, 81, 97, 121, 85, 20, 12].include? country_id
    [29, 34, 36, 46, 60, 63, 75, 100].include? country_id
  end

  def report_format_progress(actual, target)
    return 0 if target.is_a?(String) || target.zero? || !target
    ((actual.to_f / target.to_f) * 100).floor
  end
end
