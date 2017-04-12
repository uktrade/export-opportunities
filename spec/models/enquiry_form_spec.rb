require 'rails_helper'

RSpec.describe EnquiryForm do
  subject { EnquiryForm.new({}) }

  describe '#order_by' do
    it 'defaults :desc' do
      expect(subject.order_by).to eq :desc
    end
  end

  describe '#order_column' do
    it 'defaults to :created_by' do
      expect(subject.order_column).to eq :created_at
    end
  end

  describe '#dates?' do
    it 'is true when dates are set' do
      params = create_params(10.days.ago, Time.zone.today)
      expect(EnquiryForm.new(params)).to be_dates
    end
  end

  describe '#from' do
    it 'sets the from date' do
      params = create_params(Time.zone.today - 10.days, Time.zone.today)
      expect(EnquiryForm.new(params).from).to eq(Time.zone.today - 10.days)
    end
  end

  describe '#to' do
    it 'sets the to date' do
      params = create_params(Time.zone.today - 10.days, Time.zone.today)
      expect(EnquiryForm.new(params).to).to eq(Time.zone.today)
    end
  end

  def create_params(from, to)
    {
      created_at_from: {
        year: from.year.to_s,
        month: from.month.to_s,
        day: from.day.to_s,
      },
      created_at_to: {
        year: to.year.to_s,
        month: to.month.to_s,
        day: to.day.to_s,
      },
    }
  end
end
