require 'rails_helper'

RSpec.describe StatsPresenter do
  it 'returns the number of opportunities submitted' do
    stats = StatsCalculator::Stats.new(opportunities_submitted: 1, opportunities_published: 0, enquiries: 0, average_age_when_published: nil)
    expect(StatsPresenter.new(stats).opportunities_submitted).to eq 1
  end

  it 'returns the number of opportunities published' do
    stats = StatsCalculator::Stats.new(opportunities_submitted: 0, opportunities_published: 1, enquiries: 0, average_age_when_published: nil)
    expect(StatsPresenter.new(stats).opportunities_published).to eq 1
  end

  it 'returns the number of enquiries recieved' do
    stats = StatsCalculator::Stats.new(opportunities_submitted: 0, opportunities_published: 0, enquiries: 1, average_age_when_published: nil)
    expect(StatsPresenter.new(stats).enquiries).to eq 1
  end

  describe '#average_age_when_published' do
    it 'reports a quantity of days and hours' do
      stats = StatsCalculator::Stats.new(opportunities_submitted: 0, opportunities_published: 0, enquiries: 1, average_age_when_published: 54)
      expect(StatsPresenter.new(stats).average_age_when_published).to eq '2 days and 6 hours'
    end

    it 'reports a single day ' do
      stats = StatsCalculator::Stats.new(opportunities_submitted: 0, opportunities_published: 0, enquiries: 1, average_age_when_published: 24)
      expect(StatsPresenter.new(stats).average_age_when_published).to eq '1 day'
    end

    it 'reports N/A if there is no data' do
      stats = StatsCalculator::Stats.new(opportunities_submitted: 0, opportunities_published: 0, enquiries: 1, average_age_when_published: nil)
      expect(StatsPresenter.new(stats).average_age_when_published).to eq 'N/A'
    end

    it 'reports a number of hours when the average is less than a day' do
      stats = StatsCalculator::Stats.new(opportunities_submitted: 0, opportunities_published: 0, enquiries: 1, average_age_when_published: 12)
      expect(StatsPresenter.new(stats).average_age_when_published).to eq '12 hours'
    end
  end
end
