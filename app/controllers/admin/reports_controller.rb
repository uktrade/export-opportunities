require 'matrix'

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
            start_period_date = group.last.first.beginning_of_month
            end_period_date = group.last.first.end_of_month
            @stats_search_form = StatsSearchForm.new(
              stats_from: { year: start_period_date.year, month: start_period_date.month, day: start_period_date.day },
              stats_to: { year: end_period_date.year, month: end_period_date.month, day: end_period_date.day },
              granularity: 'Country',
              country: country_id
            )

            country = Country.find(country_id)
            sc = StatsCalculator.new.call(@stats_search_form)

            if cen_network?(country_id)
              # @cen_result << [group.last.first.beginning_of_month, group.last.first.end_of_month, sc.opportunities_published, sc.enquiries, current_country.name]
              if @row_lines[current_country.name.to_s]
                @row_lines[current_country.name.to_s].opportunities_published << sc.opportunities_published
              elsif country.responses_target && country.published_target
                @row_lines[current_country.name.to_s] = CountryReport.new.call(
                   country_id,
                  sc.opportunities_published,
                  sc.enquiries,
                  current_country.name,
                  'see CEN',
                  'see CEN'
                )
              end
            elsif nbn_network?(country_id)
              # @nbn_result << [group.last.first.beginning_of_month, group.last.first.end_of_month, sc.opportunities_published, sc.enquiries, current_country.name]
              if @row_lines[current_country.name.to_s]
                @row_lines[current_country.name.to_s].opportunities_published << sc.opportunities_published
              elsif country.responses_target && country.published_target
                @row_lines[current_country.name.to_s] = CountryReport.new.call(
                    country_id,
                    sc.opportunities_published,
                    sc.enquiries,
                    current_country.name,
                    'see NBN',
                    'see NBN'
                )
              end

            else
# pp country
#               pp @row_lines
              # byebug if @row_lines.size.positive?
              if @row_lines[current_country.name.to_s]
               @row_lines[current_country.name.to_s].opportunities_published << sc.opportunities_published
              elsif country.responses_target && country.published_target
                @row_lines[current_country.name.to_s] = CountryReport.new.call(
                  country_id,
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
        @targets = fetch_targets
        cen_results, nbn_results, total_results = calculate_totals(@row_lines, @targets)
        responses_csv = ReportCSV.new(@result, calculate_months).responses

        begin
          opportunities_csv.each do |row|
            response.stream.write(row)
          end
          byebug
          [cen_results, nbn_results, total_results].each do |row, key|
            response.stream.write(format_totals(row, key))
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

    def fetch_targets
      cen_target_object = Country.find(13)
      nbn_target_object = Country.find(29)
      total_target_object = Country.find(28)
      {
        opportunities_published_target_cen: cen_target_object.published_target,
        responses_target_cen: cen_target_object.responses_target,
        opportunities_published_target_nbn: nbn_target_object.published_target,
        responses_target_nbn: nbn_target_object.responses_target,
        opportunities_published_target_total: total_target_object.published_target,
        responses_target_total: total_target_object.responses_target,
      }
    end

    def to_month(datetime)
      datetime.strftime('%b')
    end

    def date_period
      start_date = Date.new(Time.zone.today.year, 4, 1)
      end_date = start_date + 1.year - 1.day
      [start_date, end_date]
    end

    def calculate_months
      result = []
      current_year = Time.zone.today.year.to_s[2, 3]
      months_arr = %w(Apr May Jun Jul Aug Sep Oct Nov Dec Jan Feb Mar)
      months_arr.each_with_index do |month, index|
        result << if index < 9
                   month + '-' + current_year
                 else
                   month + '-' + (current_year.to_i + 1).to_s
                 end
      end
      result
    end

    def calculate_totals(row_lines, targets)
      cen_results = Struct.new(:opportunities_published, :enquiries, :opportunities_published_target, :enquiries_target).new
      nbn_results = Struct.new(:opportunities_published, :enquiries, :opportunities_published_target, :enquiries_target).new
      total_results = Struct.new(:opportunities_published, :enquiries, :opportunities_published_target, :enquiries_target).new

      cen_results.opportunities_published = Vector[0,0,0,0,0,0,0,0,0,0,0,0]
      cen_results.opportunities_published_target = targets[:opportunities_published_target_cen]
      cen_results.enquiries_target = targets[:responses_target_cen]

      nbn_results.opportunities_published = Vector[0,0,0,0,0,0,0,0,0,0,0,0]
      nbn_results.opportunities_published_target = targets[:opportunities_published_target_nbn]
      nbn_results.enquiries_target = targets[:responses_target_nbn]

      total_results.opportunities_published = Vector[0,0,0,0,0,0,0,0,0,0,0,0]
      total_results.opportunities_published_target = targets[:opportunities_published_target_total]
      total_results.enquiries_target = targets[:responses_target_total]

      row_lines.each do |row_line|
        pp row_line
        row_line = row_line.drop(1).first

        if cen_network?(row_line.country_id)
          cen_results.opportunities_published = Vector.elements(cen_results.opportunities_published) + Vector.elements(row_line.opportunities_published)
          pp "CEN NETWORK"
          pp cen_results.opportunities_published
        end
        if nbn_network?(row_line.country_id)
          nbn_results.opportunities_published = Vector.elements(nbn_results.opportunities_published) + Vector.elements(row_line.opportunities_published)
          pp "NBN NETWORK"
          pp nbn_results.opportunities_published
        end
        # pp total_results.opportunities_published
        # pp row_line.opportunities_published
        total_results.opportunities_published = Vector.elements(total_results.opportunities_published) + Vector.elements(row_line.opportunities_published)
      end
      [cen_results, nbn_results, total_results]
    end

    def format_totals(row, title)
      ytd_actual = row.opportunities_published.inject(0, :+)
      line = [
          title,
          row.opportunities_published.join(','),
          ytd_actual,
          row.opportunities_published_target,
          format_progress(ytd_actual, result_line.opportunities_published_target),
      ]

      CSV.generate_line(line)
    end
  end
end
