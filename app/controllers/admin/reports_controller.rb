module Admin
  class ReportsController < BaseController
    include ActionController::Live
    include ReportHelper

    Report = ImmutableStruct.new(:country, :months, :response_target)

    def index
      authorize :reports

      if params[:commit]
        @result = {}
        @cen_result = []
        @nbn_result = []
        @row_lines = {}
        start_date, end_date = date_period
        Country.all.each do |current_country|
          country_id = current_country.id
          (start_date..end_date).group_by { |a| [a.year, a.month] }.map do |group|
            @stats_search_form = StatsSearchForm.new(
              date_from: group.last.first.beginning_of_month,
              date_to: group.last.first.end_of_month,
              granularity: 'Country',
              country: country_id
            )

            sc = StatsCalculator.new.call(@stats_search_form)

            if cen_network?(country_id)
              @cen_result << [group.last.first.beginning_of_month, group.last.first.end_of_month, sc.opportunities_published, sc.enquiries, current_country.name]
            elsif nbn_network?(country_id)
              @nbn_result << [group.last.first.beginning_of_month, group.last.first.end_of_month, sc.opportunities_published, sc.enquiries, current_country.name]
            else
              country = Country.find(country_id)
              if @row_lines[current_country.name.to_s]
                @row_lines[current_country.name.to_s].opportunities_published << sc.opportunities_published
              elsif country.responses_target && country.published_target && country.responses_target.positive? && country.published_target.positive?
                @row_lines[current_country.name.to_s] = CountryReport.new.call(
                  sc.opportunities_published,
                  sc.enquiries,
                  current_country.name,
                  country.published_target,
                  country.responses_target
                )
              end
            end
          end
        end
        response.headers['Content-Disposition'] = 'attachment; filename=monthly_by_country_report'
        response.headers['Content-Type'] = 'text/csv; charset=utf-8'

        opportunities_csv = ReportCSV.new(@row_lines, calculate_months).opportunities
        # responses_csv = ReportCSV.new(@result, calculate_months).responses

        begin
          opportunities_csv.each do |row|
            response.stream.write(row)
          end
          # responses_csv.each do |row|
          #   response.stream.write(row)
          # end
        ensure
          response.stream.close
        end

      end
    end

    private

    def to_month(datetime)
      datetime.strftime('%b')
    end

    def date_period
      start_date = Date.new(Time.zone.today.year, 4, 1)
      end_date = start_date + 1.year
      [start_date, end_date]
    end

    def calculate_months
      result = []
      current_year = Time.zone.today.year.to_s[2, 3]
      months_arr = %w(Apr May Jun Jul Aug Sep Oct Nov Dec Jan Feb Mar)
      months_arr.each do |month|
        result << month + '-' + current_year
      end
      result
    end
  end
end
