require 'csv'

class ReportCSV

  def initialize(result, months)
    @result = result
    @csv_headers = [
      'Country',
      months.flatten,
      'YTD Actual',
      'Annual Target',
      '%YTD vs Target',
    ]
  end

  def each
    return enum_for(:each) unless block_given?

    yield header

    @result.each do |result_line|
      yield row_for(result_line)
    end
  end

  private def header
    @csv_headers.join(',') + "\n"
  end

  private def row_for(result_line)
    byebug
    line = [
      result_line.country,
      result_line.opportunities_published,
      result_line.enquiries,
      format_progress(result_line.ytd_actual, result_line.opportunities_published_target),
    ]
    CSV.generate_line(line)
  end

  private def format_datetime(datetime)
    datetime.nil? ? nil : datetime.to_s(:db)
  end

  private def format_progress(actual, target)
    return '' if target==0
    ((actual.to_f/target.to_f)*100).floor
  end


end
