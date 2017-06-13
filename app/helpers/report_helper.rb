module ReportHelper
  def cen_network?(country_id)
    [82, 105, 65, 69, 96,162, 174, 23, 21, 165, 142, 115, 147, 119, 160].include? country_id
  end

  def nbn_network?(country_id)
    [34, 77, 81, 97, 121, 85, 20, 12].include? country_id
  end
end
