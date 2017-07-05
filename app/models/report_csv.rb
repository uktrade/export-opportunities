require 'csv'

class ReportCSV
  include ReportHelper

  def initialize(result, months)
    @result = result
    @reporting_months = months
    @csv_headers = [
      'Country',
      @reporting_months.flatten,
      'YTD Actual',
      'Annual Target',
      '%YTD vs Target',
    ]
  end

  def opportunities
    self
  end

  def responses
    self
  end

  def each
    return enum_for(:each) unless block_given?

    yield header

    @result.each do |result_line|
      yield row_for(result_line.drop(1).first)
    end
  end

  private def header
    @csv_headers.join(',') + "\n"
  end

  private def row_for(result_line)
    ytd_actual = result_line.opportunities_published.inject(0, :+)
    line = [
          result_line.country_id,
          result_line.name,
          result_line.opportunities_published.join(','),
          ytd_actual,
          result_line.opportunities_published_target,
          report_format_progress(ytd_actual, result_line.opportunities_published_target),
         ]

    CSV.generate_line(line)
  end

  private def format_datetime(datetime)
    datetime.nil? ? nil : datetime.to_s(:db)
  end
end
