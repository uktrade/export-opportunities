require 'rails_helper'

RSpec.describe SendMonthlyReportToMatchingAdminUser, :elasticsearch, :commit, sidekiq: :inline do
  it 'calculates date period' do
    before_end_of_financial_year = DateTime.new(2018, 3, 31).utc
    ENV["FINANCIAL_REPORTING_YEAR"] = "2017"
    Timecop.freeze(before_end_of_financial_year) do
      date_period = SendMonthlyReportToMatchingAdminUser.new.date_period
      expect(date_period.first).to eq(DateTime.new(2017, 4, 1).utc)
      expect(date_period.second).to eq(DateTime.new(2018, 3, 31).utc)
    end

    after_end_of_financial_year = DateTime.new(2018, 4, 1).utc
    ENV["FINANCIAL_REPORTING_YEAR"] = "2018"
    Timecop.freeze(after_end_of_financial_year) do
      date_period = SendMonthlyReportToMatchingAdminUser.new.date_period
      expect(date_period.first).to eq(DateTime.new(2018, 4, 1).utc)
      expect(date_period.second).to eq(DateTime.new(2019, 3, 31).utc)
    end
  end

  it 'calculates months' do
    before_end_of_financial_year = DateTime.new(2018, 3, 31).utc
    ENV["FINANCIAL_REPORTING_YEAR"] = "2017"
    Timecop.freeze(before_end_of_financial_year) do
      months = SendMonthlyReportToMatchingAdminUser.new.calculate_months
      expect(months.first).to eq 'Apr-17'
      expect(months.last).to eq 'Mar-18'
    end

    after_end_of_financial_year = DateTime.new(2018, 4, 1).utc
    ENV["FINANCIAL_REPORTING_YEAR"] = "2018"
    Timecop.freeze(after_end_of_financial_year) do
      months = SendMonthlyReportToMatchingAdminUser.new.calculate_months
      expect(months.first).to eq 'Apr-18'
      expect(months.last).to eq 'Mar-19'
    end
  end
end
