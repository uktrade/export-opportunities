require 'csv'

class ReportCSV
  CSV_HEADERS = [
      'Country',
      # month list
      'YTD Actual',
      'Annual Target',
      '%YTD vs Target',
  ].freeze

  def initialize(result)
    @result = result
  end

  def each
    return enum_for(:each) unless block_given?

    yield header

    @result.each do |result_line|
      yield row_for(result_line)
    end
  end

  private def header
    CSV_HEADERS.join(',') + "\n"
  end

  private def row_for(result_line)

    CSV.generate_line(result_line.inspect)
  end

  private def format_datetime(datetime)
    datetime.nil? ? nil : datetime.to_s(:db)
  end
end
