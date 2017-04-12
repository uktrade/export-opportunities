require 'rails_helper'

RSpec.feature 'Editors can view stats' do
  scenario 'for a specific service provider' do
    service_provider = create(:service_provider, name: 'Provider of services')
    another_service_provider = create(:service_provider, name: 'A different one')

    login_as(create(:editor, service_provider: service_provider))

    now = Time.utc(1970, 10, 1)

    stub_const('SITE_LAUNCH_YEAR', 1967)

    create(:opportunity, :unpublished, service_provider: service_provider, created_at: now - 15.days)
    create(:opportunity, :published, service_provider: service_provider, created_at: now - 100.days, first_published_at: now - 15.days)
    create(:opportunity, :published, service_provider: another_service_provider, created_at: now - 100.days, first_published_at: now - 15.days)

    enquired_opp = create(:opportunity, :published, service_provider: service_provider, created_at: now - 100.days, first_published_at: now - 100.days)
    create(:enquiry, opportunity: enquired_opp, created_at: now - 15.days)

    Timecop.freeze(now) do
      visit '/admin'

      click_on 'Stats'

      expect(page).to have_select('stats_from_year', options: %w(1967 1968 1969 1970))
      expect(page).to have_select('stats_to_year', options: %w(1967 1968 1969 1970))

      expect(page.find('#stats_from_year').value).to eq '1970'
      expect(page.find('#stats_from_month').value).to eq '9'
      expect(page.find('#stats_from_day').value).to eq '1'

      expect(page.find('#stats_to_year').value).to eq '1970'
      expect(page.find('#stats_to_month').value).to eq '9'
      expect(page.find('#stats_to_day').value).to eq '30'

      expect(page.find_field('Service provider').find('option[selected]').text).to eq 'Provider of services'

      expect(page).to have_content(t('admin.stats.opportunities_submitted', count: 1))
      expect(page).to have_content(t('admin.stats.opportunities_published', count: 1))
      expect(page).to have_content(t('admin.stats.enquiries', count: 1))

      select '1970', from: 'stats_from_year'
      select 'September', from: 'stats_from_month'
      select '10', from: 'stats_from_day'

      select '1970', from: 'stats_to_year'
      select 'September', from: 'stats_to_month'
      select '20', from: 'stats_to_day'

      click_on 'Show stats'

      expect(page.find('#stats_from_year').value).to eq '1970'
      expect(page.find('#stats_from_month').value).to eq '9'
      expect(page.find('#stats_from_day').value).to eq '10'

      expect(page.find('#stats_to_year').value).to eq '1970'
      expect(page.find('#stats_to_month').value).to eq '9'
      expect(page.find('#stats_to_day').value).to eq '20'

      expect(page.find_field('Service provider').find('option[selected]').text).to eq 'Provider of services'

      expect(page).to have_content('Statistics for Provider of services over the period 10 Sep 1970 to 20 Sep 1970')

      expect(page).to have_content(t('admin.stats.opportunities_submitted', count: 1))
      expect(page).to have_content(t('admin.stats.opportunities_published', count: 1))
      expect(page).to have_content(t('admin.stats.enquiries', count: 1))
      expect(page).to have_content(t('admin.stats.average_age_when_published', average_age: '85 days'))

      select 'A different one', from: 'Service provider'

      click_on 'Show stats'

      expect(page.find_field('Service provider').find('option[selected]').text).to eq 'A different one'
      expect(page).to have_content(t('admin.stats.opportunities_submitted', count: 0))
      expect(page).to have_content(t('admin.stats.opportunities_published', count: 1))
      expect(page).to have_content(t('admin.stats.enquiries', count: 0))
      expect(page).to have_content(t('admin.stats.average_age_when_published', average_age: '85 days'))
    end
  end

  scenario 'when there is no data for the selected criteria' do
    service_provider = create(:service_provider, name: 'A provider of services')
    login_as(create(:editor, service_provider: service_provider))

    visit '/admin/stats'

    click_on 'Show stats'

    expect(page).to have_content('Statistics for A provider of services')
    expect(page).to have_content(t('admin.stats.opportunities_submitted', count: 0))
    expect(page).to have_content(t('admin.stats.opportunities_published', count: 0))
    expect(page).to have_content(t('admin.stats.enquiries', count: 0))
    expect(page).to have_content(t('admin.stats.average_age_when_published', average_age: 'N/A'))
  end

  scenario 'when the editor has no service provider' do
    create(:service_provider, name: 'A random service provider so that the list is not empty')
    login_as(create(:editor, service_provider: nil))

    visit '/admin/stats'

    expect(page.find_field('Service provider').value).to eq StatsSearchForm::AllServiceProviders.id
    expect(page).to have_content(t('admin.stats.errors.missing_service_provider'))

    expect(page).to have_no_content('Statistics for')
    expect(page).to have_no_content(t('admin.stats.opportunities_submitted'))
    expect(page).to have_no_content(t('admin.stats.opportunities_published'))
    expect(page).to have_no_content(t('admin.stats.enquiries'))
    expect(page).to have_no_content(t('admin.stats.average_age_when_published', average_age: 'N/A'))
  end

  scenario 'when the editor requests a date range covering a single day' do
    service_provider = create(:service_provider, name: 'A provider of services')
    login_as(create(:editor, service_provider: service_provider))

    Timecop.freeze(Date.new(2015, 10, 1)) do
      visit '/admin/stats'

      select '2015', from: 'stats_from_year'
      select 'September', from: 'stats_from_month'
      select '10', from: 'stats_from_day'

      select '2015', from: 'stats_to_year'
      select 'September', from: 'stats_to_month'
      select '10', from: 'stats_to_day'

      click_on 'Show stats'

      expect(page).to have_content('Statistics for A provider of services on 10 Sep 2015')
    end
  end

  scenario 'when a non-editor tries to view the page' do
    visit '/admin/stats'

    expect(page).to have_no_content('Stats')
    expect(page).to have_content(t('devise.failure.unauthenticated'))
  end

  scenario 'for all service providers' do
    nassau = create(:service_provider, name: 'Nassau')
    mexico = create(:service_provider, name: 'Mexico')

    create(:opportunity, :published, service_provider: nassau, first_published_at: Date.new(2015, 9, 15))
    create(:opportunity, :published, service_provider: mexico, first_published_at: Date.new(2015, 9, 15))

    login_as(create(:editor))
    Timecop.freeze(Date.new(2015, 10, 1)) do
      visit '/admin/stats'

      select '2015', from: 'stats_from_year'
      select 'September', from: 'stats_from_month'
      select '15', from: 'stats_from_day'

      select '2015', from: 'stats_to_year'
      select 'September', from: 'stats_to_month'
      select '15', from: 'stats_to_day'

      select 'all service providers', from: 'Service provider'

      click_on 'Show stats'
    end

    expect(page).to have_content('Statistics for all service providers on 15 Sep 2015')
    expect(page).to have_content(t('admin.stats.opportunities_published', count: 2))
  end
end
