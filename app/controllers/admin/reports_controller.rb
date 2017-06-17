module Admin
  class ReportsController < BaseController
    include ActionController::Live
    include ReportHelper

    def index
      authorize :reports

      if params[:commit]
        @result = []
        @cen_result = []
        @nbn_result = []
        # get reporting period, 12 months back from beginning of current month
        start_date, end_date = date_period
        Country.all.each do |current_country|
          country_id = current_country.id
          (start_date..end_date).group_by { |a| [a.year, a.month] }.map do |group|
            @stats_search_form = StatsSearchForm.new(
              date_from: group.last.first.beginning_of_month,
              date_to: group.last.first.end_of_month,
              granularity: 'Country',
              country: country_id,
            )

            sc = StatsCalculator.new.call(@stats_search_form)

            if cen_network?(country_id)
              @cen_result << [group.last.first.beginning_of_month, group.last.first.end_of_month, sc.opportunities_published, sc.enquiries, current_country.name]
            elsif nbn_network?(country_id)
              @nbn_result << [group.last.first.beginning_of_month, group.last.first.end_of_month, sc.opportunities_published, sc.enquiries, current_country.name]
            else
              country = Country.where(name: current_country.name).first

              @result << [ group.last.first.beginning_of_month, group.last.first.end_of_month, sc.opportunities_published, sc.enquiries, current_country.name, country.published_target, country.responses_target]
            end
          end
        end

        response.headers['Content-Disposition'] = 'attachment; filename=monthly_by_country_report'
        response.headers['Content-Type'] = 'text/csv; charset=utf-8'

        csv = ReportCSV.new(@result)

        begin
          csv.each do |row|
            response.stream.write(row)
          end
        ensure
          response.stream.close
        end

      end
    end

    private

    def date_period
      end_date = DateTime.now.beginning_of_month
      start_date = end_date - 1.year
      [start_date, end_date]
    end
  end
end
