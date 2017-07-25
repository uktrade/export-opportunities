require 'rails_helper'

RSpec.describe StatsSearchForm do
  describe '#service_providers' do
    it 'returns service providers ordered by name' do
      xanadu = create(:service_provider, name: 'Xanadu')
      aachen = create(:service_provider, name: 'Aachen')
      london = create(:service_provider, name: 'London')

      form = StatsSearchForm.new({})
      expect(form.service_providers).to eq [aachen, london, xanadu]
    end
  end

  describe '#service_provider_id' do
    it 'returns the id which was passed in' do
      params = { granularity: 'Country', Region: { region_ids: [''] }, Country: { country_ids: ['120', '2', ''] }, ServiceProvider: { service_provider_ids: ['17'] } }
      expect(StatsSearchForm.new(params).service_provider_id).to eq [17]
    end
  end

  describe '#date_from' do
    it 'has a default value of 30 days ago' do
      Timecop.freeze(Date.new(1998, 10, 14)) do
        expect(StatsSearchForm.new({}).date_from).to eq Date.new(1998, 9, 14)
      end
    end

    it 'returns a date based on the data passed in' do
      date_hash = { year: '1998', month: '6', day: '1' }
      expect(StatsSearchForm.new(stats_from: date_hash).date_from).to eq Date.new(1998, 6, 1)
    end
  end

  describe '#date_to' do
    it 'has a default value of yesterday' do
      Timecop.freeze(Date.new(1998, 10, 14)) do
        expect(StatsSearchForm.new({}).date_to).to eq Date.new(1998, 10, 13)
      end
    end

    it 'returns a date based on the data passed in' do
      date_hash = { year: '1998', month: '7', day: '12' }
      expect(StatsSearchForm.new(stats_to: date_hash).date_to).to eq Date.new(1998, 7, 12)
    end
  end

  describe 'error_messages' do
    it 'is empty by default' do
      expect(StatsSearchForm.new({}).error_messages).to eq []
    end
  end

  describe '#valid?' do
    it 'is valid when it has a service provider and from- and to- dates' do
      from_date = { year: '2017', month: '1', day: '1' }
      to_date = { year: '2017', month: '2', day: '1' }
      params = { granularity: 'Country', Region: { region_ids: [''] }, Country: { country_ids: ['120', '2', ''] }, ServiceProvider: { service_provider_ids: ['17'] }, stats_from: from_date, stats_to: to_date }
      form = StatsSearchForm.new(params)
      expect(form.valid?).to eq true
      expect(form.error_messages).to be_empty
    end

    it 'is invalid without a service provider' do
      form = StatsSearchForm.new(service_provider_id: nil)
      expect(form.valid?).to eq false
      expect(form.error_messages).to include(t('admin.stats.errors.missing_service_provider_country_or_region'))
    end

    it 'is valid when the from_date is before the to_date' do
      earlier_date = { year: '2016', month: '1', day: '1' }
      later_date = { year: '2017', month: '1', day: '1' }
      params = { granularity: 'Country', Region: { region_ids: [''] }, Country: { country_ids: ['120', '2', ''] }, ServiceProvider: { service_provider_ids: ['17'] }, stats_from: earlier_date, stats_to: later_date }
      form = StatsSearchForm.new(params)
      expect(form.valid?).to eq true
    end

    it 'is valid when the from_date is the same as the to_date' do
      date = { year: '2017', month: '1', day: '1' }
      params = { granularity: 'Country', Region: { region_ids: [''] }, Country: { country_ids: ['120', '2', ''] }, ServiceProvider: { service_provider_ids: ['17'] }, stats_from: date, stats_to: date }
      form = StatsSearchForm.new(params)
      expect(form.valid?).to eq true
    end

    it 'is invalid when the from_date comes after the to_date' do
      earlier_date = { year: '2016', month: '1', day: '1' }
      later_date = { year: '2017', month: '1', day: '1' }
      form = StatsSearchForm.new(service_provider_id: 1, stats_from: later_date, stats_to: earlier_date)
      expect(form.valid?).to eq false
      expect(form.error_messages).to include(t('admin.stats.errors.dates_out_of_order'))
    end

    it 'is invalid when the to_date is invalid' do
      valid_date = { year: '2017', month: '2', day: '1' }
      invalid_date = { year: '2017', month: '2', day: '30' }
      form = StatsSearchForm.new(service_provider_id: 1, stats_from: valid_date, stats_to: invalid_date)
      expect(form.valid?).to eq false
      expect(form.error_messages).to include(t('admin.stats.errors.invalid_date', field: 'To'))
    end

    it 'is invalid when the from_date is invalid' do
      valid_date = { year: '2017', month: '2', day: '1' }
      invalid_date = { year: '2017', month: '2', day: '30' }
      form = StatsSearchForm.new(service_provider_id: 1, stats_from: invalid_date, stats_to: valid_date)
      expect(form.valid?).to eq false
      expect(form.error_messages).to include(t('admin.stats.errors.invalid_date', field: 'From'))
    end

    it 'is invalid when the from- or to-date is before SITE_LAUNCH_YEAR or after today' do
      stub_const('SITE_LAUNCH_YEAR', 1985)
      invalid_date_too_early = { year: '1984', month: '2', day: '1' }
      invalid_date_too_late = { year: Date.current.year + 1, month: '2', day: '1' }
      form = StatsSearchForm.new(service_provider_id: 1, stats_from: invalid_date_too_early, stats_to: invalid_date_too_late)
      expect(form.valid?).to eq false
      expect(form.error_messages).to include(t('admin.stats.errors.invalid_date', field: 'From'))
      expect(form.error_messages).to include(t('admin.stats.errors.invalid_date', field: 'To'))
    end
  end
end
