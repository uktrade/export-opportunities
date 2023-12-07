require 'matrix'
require 'csv'

class SendMonthlyReportToMatchingAdminUser < ActiveJob::Base
  include ReportHelper
  sidekiq_options retry: false

  def perform(current_editor_email, params)
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
          Country: { country_ids: [country_id] }
        )

        sc = StatsCalculator.new.call(@stats_search_form)

        if cen_network?(country_id)
          if @row_lines[current_country.name.to_s]
            @row_lines[current_country.name.to_s].opportunities_published << sc.opportunities_published
            @row_lines[current_country.name.to_s].responses << sc.enquiries
          elsif current_country.responses_target && current_country.published_target
            @row_lines[current_country.name.to_s] = CountryReport.new.call(
              country_id,
              sc.opportunities_published,
              sc.enquiries,
              current_country.name,
              'see CEN',
              'see CEN'
            )
          else
            Rails.logger.info 'cant calculate report for country:1'
            Rails.logger.info(current_country)
          end
        elsif nbn_network?(country_id)
          if @row_lines[current_country.name.to_s]
            @row_lines[current_country.name.to_s].opportunities_published << sc.opportunities_published
            @row_lines[current_country.name.to_s].responses << sc.enquiries
          elsif current_country.responses_target && current_country.published_target
            @row_lines[current_country.name.to_s] = CountryReport.new.call(
              country_id,
              sc.opportunities_published,
              sc.enquiries,
              current_country.name,
              'see NBN',
              'see NBN'
            )
          else
            Rails.logger.info 'cant calculate report for country:2'
            Rails.logger.info(current_country)
          end
        elsif @row_lines[current_country.name.to_s]
          @row_lines[current_country.name.to_s].opportunities_published << sc.opportunities_published
          @row_lines[current_country.name.to_s].responses << sc.enquiries
        elsif current_country.responses_target && current_country.published_target
          @row_lines[current_country.name.to_s] = CountryReport.new.call(
            country_id,
            sc.opportunities_published,
            sc.enquiries,
            current_country.name,
            current_country.published_target,
            current_country.responses_target
          )
        else
          Rails.logger.info 'cant calculate report for country:3'
          Rails.logger.info(current_country)
        end
      end
    end

    opportunities_csv = ReportCSV.new(@row_lines, calculate_months)
    @targets = fetch_targets
    cen_results, nbn_results, total_results = calculate_totals(@row_lines, @targets)
    responses_csv = ReportCSV.new(@row_lines, @targets)

    csv << ['======OPPORTUNITIES=======\n']
    opportunities_csv.each_opportunities do |row|
      csv << CSV.generate_line([row])
    end
    results = [cen_results, nbn_results, total_results]
    results.each do |row|
      csv << CSV.generate_line([format_opportunity_totals(row)])
    end
    csv << ['======RESPONSES=======\n']
    responses_csv.each_responses do |row|
      csv << CSV.generate_line([row])
    end
    results = [cen_results, nbn_results, total_results]
    results.each do |row|
      csv << CSV.generate_line([format_response_totals(row)])
    end
    MonthlyCountryReportMailer.send_report(csv, current_editor_email).deliver_later!
    CreateReportAudit.new.call(current_editor_email, 'monthly_report_country_vs_target', params.to_json)
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
    start_date = Date.new(financial_year_end, 4, 1)
    end_date = start_date + 1.year - 1.day
    [start_date, end_date]
  end

  def calculate_months
    result = []
    year = financial_year_end
    months_arr = %w[Apr May Jun Jul Aug Sep Oct Nov Dec Jan Feb Mar]
    months_arr.each_with_index do |month, index|
      result << if index < 9
                  month + '-' + year.to_s[2, 3]
                else
                  month + '-' + (year.to_s[2, 3].to_i + 1).to_s
                end
    end
    result
  end

  def financial_year_end
    return Figaro.env.FINANCIAL_REPORTING_YEAR.to_i if Figaro.env.FINANCIAL_REPORTING_YEAR

    today = Time.zone.now
    if today.month < 4
      (today.year - 1)
    else
      today.year
    end
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
