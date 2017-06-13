module Admin
  class ReportsController < BaseController
    include ReportHelper

    def index
      authorize :reports

      if params[:commit]
        @result = []
        @cen_result = []
        @nbn_result = []
        start_date, end_date = date_period
        Country.all.each do |current_country|
          country_id = current_country.id

          @stats_search_form = StatsSearchForm.new(
            date_from: start_date,
            date_to: end_date,
            granularity: 'Country',
            country: country_id,
          )

          sc = StatsCalculator.new.call(@stats_search_form)

          if cen_network?(country_id)
            @cen_result << [sc.opportunities_published, sc.enquiries, current_country.name]
          elsif nbn_network?(country_id)
            @nbn_result << [sc.opportunities_published, sc.enquiries, current_country.name]
          else
            @result << [sc.opportunities_published, sc.enquiries, current_country.name]
          end
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
