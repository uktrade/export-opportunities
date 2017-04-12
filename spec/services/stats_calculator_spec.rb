require 'rails_helper'

RSpec.describe StatsCalculator do
  describe '#call' do
    context 'when a single service provider is requested' do
      describe '.opportunities_submitted' do
        it 'returns the number of opportunities submitted during the selected date range (inclusive) for the selected service provider' do
          service_provider = create(:service_provider, name: 'Provider of services')
          another_service_provider = create(:service_provider, name: 'A different one')

          lower_limit = Time.zone.today - 20.days
          upper_limit = Time.zone.today - 10.days

          create(:opportunity, :unpublished, service_provider: service_provider, created_at: lower_limit - 1.day)
          create(:opportunity, :unpublished, service_provider: service_provider, created_at: lower_limit)
          create(:opportunity, :unpublished, service_provider: service_provider, created_at: upper_limit)
          create(:opportunity, :unpublished, service_provider: service_provider, created_at: upper_limit + 1.day)

          create(:opportunity, :unpublished, service_provider: another_service_provider, created_at: lower_limit + 1.day)

          fake_criteria = instance_double('StatsSearchForm', date_from: lower_limit, date_to: upper_limit, service_provider_id: service_provider, all_service_providers?: false)
          expect(StatsCalculator.new.call(fake_criteria).opportunities_submitted).to eq 2
        end
      end

      describe '.opportunities_published' do
        it 'returns the number of opportunities published during the selected date range (inclusive) for the selected service provider' do
          service_provider = create(:service_provider, name: 'Provider of services')
          another_service_provider = create(:service_provider, name: 'A different one')

          lower_limit = Time.zone.today - 20.days
          upper_limit = Time.zone.today - 10.days

          create(:opportunity, :published, service_provider: service_provider, first_published_at: lower_limit - 1.day)
          create(:opportunity, :published, service_provider: service_provider, first_published_at: lower_limit)
          create(:opportunity, :published, service_provider: service_provider, first_published_at: upper_limit)
          create(:opportunity, :published, service_provider: service_provider, first_published_at: upper_limit + 1.day)

          create(:opportunity, :published, service_provider: another_service_provider, first_published_at: lower_limit + 1.day)

          fake_criteria = instance_double('StatsSearchForm', date_from: lower_limit, date_to: upper_limit, service_provider_id: service_provider, all_service_providers?: false)
          expect(StatsCalculator.new.call(fake_criteria).opportunities_published).to eq 2
        end

        it 'includes opportunities which were published, then later unpublished' do
          service_provider = create(:service_provider, name: 'Provider of services')

          lower_limit = Time.zone.today - 20.days
          upper_limit = Time.zone.today - 10.days

          create(:opportunity, :unpublished, service_provider: service_provider, first_published_at: lower_limit + 1.day)

          fake_criteria = instance_double('StatsSearchForm', date_from: lower_limit, date_to: upper_limit, service_provider_id: service_provider, all_service_providers?: false)
          expect(StatsCalculator.new.call(fake_criteria).opportunities_published).to eq 1
        end

        it 'includes opportunities which were published, then later trashed' do
          service_provider = create(:service_provider, name: 'Provider of services')

          lower_limit = Time.zone.today - 20.days
          upper_limit = Time.zone.today - 10.days

          create(:opportunity, status: :trash, service_provider: service_provider, first_published_at: lower_limit + 1.day)

          fake_criteria = instance_double('StatsSearchForm', date_from: lower_limit, date_to: upper_limit, service_provider_id: service_provider, all_service_providers?: false)
          expect(StatsCalculator.new.call(fake_criteria).opportunities_published).to eq 1
        end
      end

      describe '.enquiries' do
        it 'returns the number of enquiries published during the selected date range (inclusive) for the selected service provider' do
          service_provider = create(:service_provider, name: 'Provider of services')
          another_service_provider = create(:service_provider, name: 'A different one')

          lower_limit = Time.zone.today - 20.days
          upper_limit = Time.zone.today - 10.days

          matching_opportunity = create(:opportunity, :published, service_provider: service_provider)
          non_matching_opportunity = create(:opportunity, :published, service_provider: another_service_provider)

          create(:enquiry, opportunity: matching_opportunity, created_at: lower_limit - 1.day)
          create(:enquiry, opportunity: matching_opportunity, created_at: lower_limit)
          create(:enquiry, opportunity: matching_opportunity, created_at: upper_limit)
          create(:enquiry, opportunity: matching_opportunity, created_at: upper_limit + 1.day)

          create(:enquiry, opportunity: non_matching_opportunity, created_at: lower_limit + 1.day)

          fake_criteria = instance_double('StatsSearchForm', date_from: lower_limit, date_to: upper_limit, service_provider_id: service_provider, all_service_providers?: false)
          expect(StatsCalculator.new.call(fake_criteria).enquiries).to eq 2
        end
      end

      describe '.average_age_when_published' do
        it 'returns an integer representing the average number of hours between opportunity creation and publication for the selected service provider' do
          service_provider = create(:service_provider, name: 'Provider of services')
          another_service_provider = create(:service_provider, name: 'A different one')

          lower_limit = Time.zone.today - 20.days
          upper_limit = Time.zone.today - 10.days

          creation_date = lower_limit - 5.days

          create(:opportunity, :published, service_provider: service_provider, first_published_at: lower_limit - 1.day, created_at: creation_date)
          create(:opportunity, :published, service_provider: service_provider, first_published_at: upper_limit + 1.day, created_at: creation_date)

          create(:opportunity, :published, service_provider: service_provider, first_published_at: lower_limit, created_at: creation_date)
          create(:opportunity, :published, service_provider: service_provider, first_published_at: lower_limit + 1.day, created_at: creation_date)
          create(:opportunity, :published, service_provider: service_provider, first_published_at: lower_limit + 2.days, created_at: creation_date)

          create(:opportunity, :published, service_provider: another_service_provider, first_published_at: lower_limit, created_at: creation_date)

          fake_criteria = instance_double('StatsSearchForm', date_from: lower_limit, date_to: upper_limit, service_provider_id: service_provider, all_service_providers?: false)
          expect(StatsCalculator.new.call(fake_criteria).average_age_when_published).to eq 144
        end
      end

      context 'when there is no data' do
        it 'returns a result object with zeros in each place' do
          fake_criteria = instance_double('StatsSearchForm', date_from: nil, date_to: nil, service_provider_id: nil, all_service_providers?: false)
          result = StatsCalculator.new.call(fake_criteria)
          aggregate_failures do
            expect(result.opportunities_submitted).to eq 0
            expect(result.opportunities_published).to eq 0
            expect(result.enquiries).to eq 0
            expect(result.average_age_when_published).to eq nil
          end
        end
      end
    end

    context 'when all service providers are requested' do
      describe '.opportunities_submitted' do
        it 'returns the number of opportunities submitted during the selected date range (inclusive) for the selected service provider' do
          service_provider = create(:service_provider, name: 'Provider of services')
          another_service_provider = create(:service_provider, name: 'A different one')

          lower_limit = Time.zone.today - 20.days
          upper_limit = Time.zone.today - 10.days

          create(:opportunity, :unpublished, service_provider: service_provider, created_at: lower_limit - 1.day)
          create(:opportunity, :unpublished, service_provider: service_provider, created_at: lower_limit)
          create(:opportunity, :unpublished, service_provider: service_provider, created_at: upper_limit)
          create(:opportunity, :unpublished, service_provider: service_provider, created_at: upper_limit + 1.day)

          create(:opportunity, :unpublished, service_provider: another_service_provider, created_at: lower_limit + 1.day)

          fake_criteria = instance_double('StatsSearchForm', date_from: lower_limit, date_to: upper_limit, all_service_providers?: true)
          expect(StatsCalculator.new.call(fake_criteria).opportunities_submitted).to eq 3
        end
      end

      describe '.opportunities_published' do
        it 'returns the number of opportunities published during the selected date range (inclusive) for the selected service provider' do
          service_provider = create(:service_provider, name: 'Provider of services')
          another_service_provider = create(:service_provider, name: 'A different one')

          lower_limit = Time.zone.today - 20.days
          upper_limit = Time.zone.today - 10.days

          create(:opportunity, :published, service_provider: service_provider, first_published_at: lower_limit - 1.day)
          create(:opportunity, :published, service_provider: service_provider, first_published_at: lower_limit)
          create(:opportunity, :published, service_provider: service_provider, first_published_at: upper_limit)
          create(:opportunity, :published, service_provider: service_provider, first_published_at: upper_limit + 1.day)

          create(:opportunity, :published, service_provider: another_service_provider, first_published_at: lower_limit + 1.day)

          fake_criteria = instance_double('StatsSearchForm', date_from: lower_limit, date_to: upper_limit, all_service_providers?: true)
          expect(StatsCalculator.new.call(fake_criteria).opportunities_published).to eq 3
        end

        it 'includes opportunities which were published, then later unpublished' do
          service_provider = create(:service_provider, name: 'Provider of services')

          lower_limit = Time.zone.today - 20.days
          upper_limit = Time.zone.today - 10.days

          create(:opportunity, :unpublished, service_provider: service_provider, first_published_at: lower_limit + 1.day)

          fake_criteria = instance_double('StatsSearchForm', date_from: lower_limit, date_to: upper_limit, all_service_providers?: true)
          expect(StatsCalculator.new.call(fake_criteria).opportunities_published).to eq 1
        end

        it 'includes opportunities which were published, then later trashed' do
          service_provider = create(:service_provider, name: 'Provider of services')

          lower_limit = Time.zone.today - 20.days
          upper_limit = Time.zone.today - 10.days

          create(:opportunity, status: :trash, service_provider: service_provider, first_published_at: lower_limit + 1.day)

          fake_criteria = instance_double('StatsSearchForm', date_from: lower_limit, date_to: upper_limit, all_service_providers?: true)
          expect(StatsCalculator.new.call(fake_criteria).opportunities_published).to eq 1
        end
      end

      describe '.enquiries' do
        it 'returns the number of enquiries published during the selected date range (inclusive) for the selected service provider' do
          service_provider = create(:service_provider, name: 'Provider of services')
          another_service_provider = create(:service_provider, name: 'A different one')

          lower_limit = Time.zone.today - 20.days
          upper_limit = Time.zone.today - 10.days

          matching_opportunity = create(:opportunity, :published, service_provider: service_provider)
          non_matching_opportunity = create(:opportunity, :published, service_provider: another_service_provider)

          create(:enquiry, opportunity: matching_opportunity, created_at: lower_limit - 1.day)
          create(:enquiry, opportunity: matching_opportunity, created_at: lower_limit)
          create(:enquiry, opportunity: matching_opportunity, created_at: upper_limit)
          create(:enquiry, opportunity: matching_opportunity, created_at: upper_limit + 1.day)

          create(:enquiry, opportunity: non_matching_opportunity, created_at: lower_limit + 1.day)

          fake_criteria = instance_double('StatsSearchForm', date_from: lower_limit, date_to: upper_limit, all_service_providers?: true)
          expect(StatsCalculator.new.call(fake_criteria).enquiries).to eq 3
        end
      end

      describe '.average_age_when_published' do
        it 'returns an integer representing the average number of hours between opportunity creation and publication for the selected service provider' do
          service_provider = create(:service_provider, name: 'Provider of services')
          another_service_provider = create(:service_provider, name: 'A different one')

          lower_limit = Time.zone.today - 20.days
          upper_limit = Time.zone.today - 10.days

          creation_date = lower_limit - 5.days

          create(:opportunity, :published, service_provider: service_provider, first_published_at: lower_limit - 1.day, created_at: creation_date)
          create(:opportunity, :published, service_provider: service_provider, first_published_at: upper_limit + 1.day, created_at: creation_date)

          create(:opportunity, :published, service_provider: service_provider, first_published_at: lower_limit, created_at: creation_date)
          create(:opportunity, :published, service_provider: another_service_provider, first_published_at: lower_limit + 1.day, created_at: creation_date)
          create(:opportunity, :published, service_provider: service_provider, first_published_at: lower_limit + 2.days, created_at: creation_date)

          fake_criteria = instance_double('StatsSearchForm', date_from: lower_limit, date_to: upper_limit, service_provider_id: service_provider, all_service_providers?: true)
          expect(StatsCalculator.new.call(fake_criteria).average_age_when_published).to eq 144
        end
      end

      context 'when there is no data' do
        it 'returns a result object with zeros in each place' do
          fake_criteria = instance_double('StatsSearchForm', date_from: nil, date_to: nil, all_service_providers?: true)
          result = StatsCalculator.new.call(fake_criteria)
          aggregate_failures do
            expect(result.opportunities_submitted).to eq 0
            expect(result.opportunities_published).to eq 0
            expect(result.enquiries).to eq 0
          end
        end
      end
    end
  end
end
