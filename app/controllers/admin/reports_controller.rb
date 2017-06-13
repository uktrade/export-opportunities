module Admin
  class ReportsController < BaseController
    def index
      authorize :reports

      if params[:commit]
        @result = []
        start_date, end_date = date_period
        [Country.find(66), Country.find(2)].each do |current_country|
          @stats_search_form = StatsSearchForm.new(
              date_from: start_date,
              date_to: end_date,
              granularity: 'Country',
              country_id: current_country,
          )
          sc = StatsCalculator.new.call(@stats_search_form)
          @result << sc
        end
        pp @result
      end
    end

    def create
      @result = []
      start_date, end_date = date_period
      [Country.find(66), Country.find(2)].each do |current_country|
        @stats_search_form = StatsSearchForm.new(
            date_from: start_date,
          date_to: end_date,
          granularity: 'Country',
          country_id: current_country,
        )
        sc = StatsCalculator.new.call(@stats_search_form)
        @result << sc
      end
      byebug
      render 'create'
    end
    private

    def date_period
      end_date = DateTime.now.beginning_of_month
      start_date = end_date-1.year
      [start_date,end_date]
    end
  end
end
