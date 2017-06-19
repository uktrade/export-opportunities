require 'csv'

class ReportCSV

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
      yield row_for(result_line)
    end
  end

  private def header
    @csv_headers.join(',') + "\n"
  end

  private def row_for(result_line)
    sum = 0
    line = [
      result_line[0],
      # result_line[1].opportunities_published,
      # result_line.enquiries,
    ]
    months_arr = %w(Apr May Jun Jul Aug Sep Oct Nov Dec Jan Feb Mar)

    months_arr.each do |reporting_month|
      byebug
      sum += result_line[1][reporting_month][:opportunities_published]
      line.push result_line[1][reporting_month][:opportunities_published]
    end
    line.push sum
    line.push format_progress(sum, result_line[2][:opportunities_published])
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
