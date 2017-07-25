require 'matrix'
require 'csv'

module Admin
  class ReportsController < BaseController
    include ActionController::Live
    include ReportHelper

    Report = ImmutableStruct.new(:country, :months, :response_target)

    ImpactStatsReport = ImmutableStruct.new(:sent, :responded, :responded_with_feedback, :option_0, :option_1, :option_2, :option_3, :option_4)

    def show
      authorize :reports
      start_date = DateTime.new(params['impact_stats_date']['data(1i)'].to_i, params['impact_stats_date']['data(2i)'].to_i, params['impact_stats_date']['data(3i)'].to_i).in_time_zone('UTC').beginning_of_day
      @stats = calculate_impact_email_stats(start_date, start_date + 1.day) if params[:id] == 'impact_email'
    end

    def index
      authorize :reports

      if params[:commit]
        csv_data = monthly_report
        MonthlyCountryReportMailer.send_report(current_editor.email, csv_data).deliver_later!
      end
    end

    private

    def monthly_report
      csv = []
      @cen_result = []
      @nbn_result = []
      @row_lines = {}
      start_date, end_date = date_period
      Country.all.each do |current_country|
        country_id = current_country.id
        (start_date..end_date).group_by { |a| [a.year, a.month] }.map do |group|
          start_period_date = group.last.first.beginning_of_month
          end_period_date = group.last.first.end_of_month + 1.day
          @stats_search_form = StatsSearchForm.new(
            stats_from: { year: start_period_date.year, month: start_period_date.month, day: start_period_date.day },
            stats_to: { year: end_period_date.year, month: end_period_date.month, day: end_period_date.day },
            granularity: 'Country',
            Country: { country_ids: country_id }
          )

          # FIX: current_country here, not country
          country = Country.find(country_id)
          sc = StatsCalculator.new.call(@stats_search_form)

          if cen_network?(country_id)
            if @row_lines[current_country.name.to_s]
              @row_lines[current_country.name.to_s].opportunities_published << sc.opportunities_published
              @row_lines[current_country.name.to_s].responses << sc.enquiries
            elsif country.responses_target && country.published_target
              @row_lines[current_country.name.to_s] = CountryReport.new.call(
                country_id,
                sc.opportunities_published,
                sc.enquiries,
                current_country.name,
                'see CEN',
                'see CEN'
              )
            else
              Rails.logger.info'cant calculate report for country:1'
              Rails.logger.info(current_country)
            end
          elsif nbn_network?(country_id)
            if @row_lines[current_country.name.to_s]
              @row_lines[current_country.name.to_s].opportunities_published << sc.opportunities_published
              @row_lines[current_country.name.to_s].responses << sc.enquiries
            elsif country.responses_target && country.published_target
              @row_lines[current_country.name.to_s] = CountryReport.new.call(
                country_id,
                sc.opportunities_published,
                sc.enquiries,
                current_country.name,
                'see NBN',
                'see NBN'
              )
            else
              Rails.logger.info'cant calculate report for country:2'
              Rails.logger.info(current_country)
            end
          elsif @row_lines[current_country.name.to_s]
            @row_lines[current_country.name.to_s].opportunities_published << sc.opportunities_published
            @row_lines[current_country.name.to_s].responses << sc.enquiries
          elsif country.responses_target && country.published_target
            @row_lines[current_country.name.to_s] = CountryReport.new.call(
              country_id,
              sc.opportunities_published,
              sc.enquiries,
              current_country.name,
              country.published_target,
              country.responses_target
            )
          else
            Rails.logger.info'cant calculate report for country:3'
            Rails.logger.info(current_country)
          end
        end
      end
      response.headers['Content-Disposition'] = 'attachment; filename=monthly_by_country_report'
      response.headers['Content-Type'] = 'text/csv; charset=utf-8'

      opportunities_csv = ReportCSV.new(@row_lines, calculate_months)
      @targets = fetch_targets
      cen_results, nbn_results, total_results = calculate_totals(@row_lines, @targets)
      responses_csv = ReportCSV.new(@row_lines, @targets)

      # begin
        csv << ("======OPPORTUNITIES=======\n")
        opportunities_csv.each_opportunities do |row|
          csv << (row)
        end
        results = [cen_results, nbn_results, total_results]
        results.each do |row|
          csv << (format_opportunity_totals(row))
        end
        csv << ("======RESPONSES=======\n")
        responses_csv.each_responses do |row|
          csv << (row)
        end
        results = [cen_results, nbn_results, total_results]
        results.each do |row|
          csv << (format_response_totals(row))
        end
      # ensure
      #   # response.stream.close
      # end
        csv
    end

    def calculate_impact_email_stats(start_date = Time.zone.now.beginning_of_day - 1.day, end_date = Time.zone.now)
      isc = ImpactStatsCalculator.new.call(start_date, end_date)

      @impact_stats = ImpactStatsReport.new(
        sent: isc.sent,
        responded: isc.responded,
        responded_with_feedback: isc.responded_with_feedback,
        option_0: isc.option_0,
        option_1: isc.option_1,
        option_2: isc.option_2,
        option_3: isc.option_3,
        option_4: isc.option_4
      )
    end

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
      cen_results = Struct.new(:title, :opportunities_published, :responses, :opportunities_published_target, :responses_target).new
      nbn_results = Struct.new(:title, :opportunities_published, :responses, :opportunities_published_target, :responses_target).new
      total_results = Struct.new(:title, :opportunities_published, :responses, :opportunities_published_target, :responses_target).new

      cen_results.opportunities_published = Vector[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      cen_results.opportunities_published_target = targets[:opportunities_published_target_cen]
      cen_results.responses = Vector[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      cen_results.responses_target = targets[:responses_target_cen]
      cen_results.title = :CEN

      nbn_results.opportunities_published = Vector[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      nbn_results.opportunities_published_target = targets[:opportunities_published_target_nbn]
      nbn_results.responses = Vector[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      nbn_results.responses_target = targets[:responses_target_nbn]
      nbn_results.title = :NBN

      total_results.opportunities_published = Vector[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      total_results.opportunities_published_target = targets[:opportunities_published_target_total]
      total_results.responses = Vector[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      total_results.responses_target = targets[:responses_target_total]
      total_results.title = :Total

      row_lines.each do |row_line|
        row_line = row_line.drop(1).first

        if cen_network?(row_line.country_id)
          cen_results.opportunities_published = Vector.elements(cen_results.opportunities_published) + Vector.elements(row_line.opportunities_published)
          cen_results.responses = Vector.elements(cen_results.responses) + Vector.elements(row_line.responses)
        end
        if nbn_network?(row_line.country_id)
          nbn_results.opportunities_published = Vector.elements(nbn_results.opportunities_published) + Vector.elements(row_line.opportunities_published)
          nbn_results.responses = Vector.elements(nbn_results.responses) + Vector.elements(row_line.responses)
        end
        total_results.opportunities_published = Vector.elements(total_results.opportunities_published) + Vector.elements(row_line.opportunities_published)
        total_results.responses = Vector.elements(total_results.responses) + Vector.elements(row_line.responses)
      end
      [cen_results, nbn_results, total_results]
    end

    def format_opportunity_totals(row)
      ytd_actual = row.opportunities_published.inject(0, :+)
      line = [
        row.title.to_s,
      ]

      row.opportunities_published.to_a.each { |elem| line << elem }

      [
        ytd_actual,
        row.opportunities_published_target,
        report_format_progress(
          ytd_actual,
          row.opportunities_published_target
        ),
      ].each { |elem| line << elem }

      CSV.generate_line(line)
    end

    def format_response_totals(row)
      ytd_actual = row.responses.inject(0, :+)
      line = [
        row.title.to_s,
      ]

      row.responses.to_a.each { |elem| line << elem }

      [
        ytd_actual,
        row.responses_target,
        report_format_progress(
          ytd_actual,
          row.responses_target
        ),
      ].each { |elem| line << elem }

      CSV.generate_line(line)
    end
  end
end
