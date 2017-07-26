require 'csv'

class ReportCSV
  include ReportHelper

  def initialize(result, months)
    @result = result
    @reporting_months = months
    @csv_headers = [
      'Country ID',
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

  def each_opportunities
    return enum_for(:each) unless block_given?

    yield header

    @result.each do |result_line|
      yield row_for_opportunities(result_line.drop(1).first)
    end
  end

  def each_responses
    return enum_for(:each) unless block_given?

    yield header

    @result.each do |result_line|
      yield row_for_responses(result_line.drop(1).first)
    end
  end
  private def header
    @csv_headers.join(',') + "\n"
  end

  private def row_for_opportunities(result_line)
    ytd_actual = result_line.opportunities_published.inject(0, :+)
    line = [
      result_line.country_id,
      result_line.name,
    ]

    result_line.opportunities_published.each { |elem| line << elem }

    [
      ytd_actual,
      result_line.opportunities_published_target,
      report_format_progress(
        ytd_actual,
        result_line.opportunities_published_target
      ),
    ].each { |elem| line << elem }

    CSV.generate_line(line)
  end

  private def row_for_responses(result_line)
    ytd_actual = result_line.responses.inject(0, :+)
    line = [
      result_line.country_id,
      result_line.name,
    ]

    result_line.responses.each { |elem| line << elem }

    # result_line.responses.join(','),
    [
      ytd_actual,
      result_line.responses_target,
      report_format_progress(
        ytd_actual,
        result_line.responses_target
      ),
    ].each { |elem| line << elem }

    CSV.generate_line(line)
  end

  private def format_datetime(datetime)
    datetime.nil? ? nil : datetime.to_s(:db)
  end
end
