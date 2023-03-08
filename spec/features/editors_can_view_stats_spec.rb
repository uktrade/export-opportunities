require 'rails_helper'

RSpec.feature 'Editors can view stats' do
  before(:all) do
    @content = get_content('admin/stats')
  end

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
      visit '/export-opportunities/admin'

      click_on 'Stats'

      expect(page.find('#stats_from_year').value).to eq '1970'
      expect(page.find('#stats_from_month').value).to eq '9'
      expect(page.find('#stats_from_day').value).to eq '1'

      expect(page.find('#stats_to_year').value).to eq '1970'
      expect(page.find('#stats_to_month').value).to eq '9'
      expect(page.find('#stats_to_day').value).to eq '30'

      # here it is expecting the service provider that the admin user belongs to, to be selected.
      # expect(page.find_field('Service provider').find('option[selected]').text).to eq 'Provider of services'

      select '1970', from: 'stats_from_year'
      select '09', from: 'stats_from_month'
      select '10', from: 'stats_from_day'

      select '1970', from: 'stats_to_year'
      select '09', from: 'stats_to_month'
      select '20', from: 'stats_to_day'

      choose 'granularity', option: 'Universe'

      click_on(@content['submit_button'], match: :first)

      expect(page.find('#stats_from_year').value).to eq '1970'
      expect(page.find('#stats_from_month').value).to eq '9'
      expect(page.find('#stats_from_day').value).to eq '10'

      expect(page.find('#stats_to_year').value).to eq '1970'
      expect(page.find('#stats_to_month').value).to eq '9'
      expect(page.find('#stats_to_day').value).to eq '20'

      expect(page).to have_content('Statistics by Universe and all sources over the period 10 Sep 1970 to 20 Sep 1970')

      expect_opportunities_submitted('1')
      expect_opportunities_published('2')
      expect_enquiries('1')
      expect_age_when_published('85 days')

      select '1970', from: 'stats_from_year'
      select '09', from: 'stats_from_month'
      select '10', from: 'stats_from_day'

      select '1970', from: 'stats_to_year'
      select '09', from: 'stats_to_month'
      select '20', from: 'stats_to_day'

      choose 'granularity', option: 'ServiceProvider'

      select 'A different one', from: 'ServiceProvider[service_provider_ids][]'

      click_on(@content['submit_button'], match: :first)

      expect_opportunities_submitted('0')
      expect_opportunities_published('1')
      expect_enquiries('0')
      expect_age_when_published('85 days')
    end
  end

  scenario 'when there is no data for the selected criteria' do
    service_provider = create(:service_provider, name: 'A provider of services')
    login_as(create(:editor, service_provider: service_provider))

    visit '/export-opportunities/admin/stats'

    choose 'granularity', option: 'ServiceProvider'

    select 'A provider of services', from: 'ServiceProvider[service_provider_ids][]'

    click_on(@content['submit_button'], match: :first)

    expect(page).to have_content('Statistics by')
    expect_opportunities_submitted('0')
    expect_opportunities_published('0')
    expect_enquiries('0')
    expect_age_when_published('N/A')
  end

  scenario 'when the editor has no service provider' do
    create(:service_provider, name: 'A random service provider so that the list is not empty')
    login_as(create(:editor, service_provider: nil))

    visit '/export-opportunities/admin/stats'
    choose 'granularity', option: 'Universe'
    click_on(@content['submit_button'], match: :first)

    expect(page).to have_content('Statistics by')
    expect_opportunities_submitted('0')
    expect_opportunities_published('0')
    expect_enquiries('0')
    expect_age_when_published('N/A')
  end

  scenario 'when the editor requests a date range covering a single day' do
    service_provider = create(:service_provider, name: 'A provider of services')
    login_as(create(:editor, service_provider: service_provider))

    Timecop.freeze(Date.new(2015, 10, 1)) do
      visit '/export-opportunities/admin/stats'

      select '2015', from: 'stats_from_year'
      select '09', from: 'stats_from_month'
      select '10', from: 'stats_from_day'

      select '2015', from: 'stats_to_year'
      select '09', from: 'stats_to_month'
      select '10', from: 'stats_to_day'

      choose 'granularity', option: 'ServiceProvider'

      select 'A provider of services', from: 'ServiceProvider[service_provider_ids][]'

      click_on(@content['submit_button'], match: :first)

      expect(page).to have_content('Statistics by ServiceProvider and all sources on 10 Sep 2015')
    end
  end

  scenario 'when a non-editor tries to view the page' do
    visit '/export-opportunities/admin/stats'

    expect(page).to have_no_content('Stats')
    expect(page).to have_content(t('devise.failure.unauthenticated'))
  end

  scenario 'for a specific country' do
    country = create(:country, name: 'Mexico')
    another_country = create(:country, name: 'Barbados')
    nassau = create(:service_provider, name: 'Nassau', country: country)
    guadalajara = create(:service_provider, name: 'Guadalajara', country: country)
    barbados = create(:service_provider, name: 'Barbados', country: another_country)

    create(:opportunity, :published, service_provider: nassau, first_published_at: Date.new(2015, 9, 15))
    create(:opportunity, :published, service_provider: guadalajara, first_published_at: Date.new(2015, 9, 15))
    create(:opportunity, :published, service_provider: barbados, first_published_at: Date.new(2015, 9, 15))

    login_as(create(:editor, service_provider: nassau))
    Timecop.freeze(Date.new(2015, 10, 1)) do
      visit '/export-opportunities/admin/stats'

      select '2015', from: 'stats_from_year'
      select '09', from: 'stats_from_month'
      select '15', from: 'stats_from_day'

      select '2015', from: 'stats_to_year'
      select '09', from: 'stats_to_month'
      select '15', from: 'stats_to_day'

      choose 'granularity', option: 'Country'

      select 'Mexico', from: 'Country[country_ids][]'

      click_on(@content['submit_button'], match: :first)
    end

    expect(page).to have_content('Statistics by Country and all sources on 15 Sep 2015')
    expect_opportunities_published('2')
  end

  scenario 'for a specific region' do
    region = create(:region, name: 'Latin America', id: 1)
    another_region = create(:region, name: 'North America', id: 2)

    country = create(:country, name: 'Mexico', region: region)
    another_country = create(:country, name: 'Canada', region: another_region)

    iztapalapa = create(:service_provider, name: 'Iztapalapa', country: country)
    mexico = create(:service_provider, name: 'Mexico City', country: country)
    alberta = create(:service_provider, name: 'Canada Alberta', country: another_country)

    create(:opportunity, :published, service_provider: iztapalapa, first_published_at: Date.new(2015, 9, 15))
    create(:opportunity, :published, service_provider: mexico, first_published_at: Date.new(2015, 9, 15))
    create(:opportunity, :published, service_provider: alberta, first_published_at: Date.new(2015, 9, 15))

    login_as(create(:editor, service_provider: iztapalapa))
    Timecop.freeze(Date.new(2015, 10, 1)) do
      visit '/export-opportunities/admin/stats'

      select '2015', from: 'stats_from_year'
      select '09', from: 'stats_from_month'
      select '15', from: 'stats_from_day'

      select '2015', from: 'stats_to_year'
      select '09', from: 'stats_to_month'
      select '15', from: 'stats_to_day'

      choose 'granularity', option: 'Region', visible: false

      select 'Latin America', from: 'Region[region_ids][]'

      click_on(@content['submit_button'], match: :first)
    end

    expect_opportunities_published('2')
    expect(page).to have_content('0 Enquiry Responses (counted at Enquiry Response created at date)')
  end

  scenario '(JS true) for a specific region', js: true do
    Capybara.ignore_hidden_elements = false

    region = create(:region, name: 'Latin America', id: 1)
    another_region = create(:region, name: 'North America', id: 2)
    country = create(:country, name: 'Mexico', region: region)
    another_country = create(:country, name: 'Canada', region: another_region)
    iztapalapa = create(:service_provider, name: 'Iztapalapa', country: country)
    mexico = create(:service_provider, name: 'Mexico City', country: country)
    alberta = create(:service_provider, name: 'Canada Alberta', country: another_country)

    create(:opportunity, :published, service_provider: iztapalapa, first_published_at: Date.new(2015, 9, 15))
    create(:opportunity, :published, service_provider: mexico, first_published_at: Date.new(2015, 9, 15))
    create(:opportunity, :published, service_provider: alberta, first_published_at: Date.new(2015, 9, 15))

    login_as(create(:editor, service_provider: iztapalapa))
    Timecop.freeze(Date.new(2015, 10, 1)) do
      visit '/export-opportunities/admin/stats'

      select '2015', from: 'stats_from_year'
      select '09', from: 'stats_from_month'
      select '15', from: 'stats_from_day'

      select '2015', from: 'stats_to_year'
      select '09', from: 'stats_to_month'
      select '15', from: 'stats_to_day'

      wait_for_ajax

      find('[name=granularity][value=Region]').trigger('click')
      select 'Latin America', from: 'Region[region_ids][]'

      find_button(@content['submit_button'], match: :first).trigger('click')
    end

    expect_opportunities_published('2')
  end

  scenario 'for all the universe' do
    region = create(:region, name: 'Latin America')
    another_region = create(:region, name: 'North America')
    country = create(:country, name: 'Mexico', region: region)
    another_country = create(:country, name: 'Barbados', region: another_region)
    nassau = create(:service_provider, name: 'Nassau', country: country)
    mexico = create(:service_provider, name: 'Mexico', country: country)
    barbados = create(:service_provider, name: 'Barbados', country: another_country)

    create(:opportunity, :published, service_provider: nassau, first_published_at: Date.new(2015, 9, 15))
    create(:opportunity, :published, service_provider: mexico, first_published_at: Date.new(2015, 9, 15))
    create(:opportunity, :published, service_provider: barbados, first_published_at: Date.new(2015, 9, 15))

    login_as(create(:editor, service_provider: nassau))
    Timecop.freeze(Date.new(2015, 10, 1)) do
      visit '/export-opportunities/admin/stats'

      select '2015', from: 'stats_from_year'
      select '09', from: 'stats_from_month'
      select '15', from: 'stats_from_day'

      select '2015', from: 'stats_to_year'
      select '09', from: 'stats_to_month'
      select '15', from: 'stats_to_day'

      choose 'granularity', option: 'Universe'

      click_on(@content['submit_button'], match: :first)
    end

    expect_opportunities_published('3')
  end

  scenario 'for all the DIT universe' do
    region = create(:region, name: 'Latin America')
    another_region = create(:region, name: 'North America')
    country = create(:country, name: 'Mexico', region: region)
    another_country = create(:country, name: 'Barbados', region: another_region)
    nassau = create(:service_provider, name: 'Nassau', country: country)
    mexico = create(:service_provider, name: 'Mexico', country: country)
    barbados = create(:service_provider, name: 'Barbados', country: another_country)

    opportunity = create(:opportunity, :published, service_provider: nassau, first_published_at: Date.new(2015, 9, 15), source: :post)
    create(:opportunity, :published, service_provider: mexico, first_published_at: Date.new(2015, 9, 15), source: :post)
    create(:opportunity, :published, service_provider: barbados, first_published_at: Date.new(2015, 9, 15), source: :volume_opps)

    enquiry = create(:enquiry, opportunity: opportunity, created_at: Date.new(2015, 9, 15))
    create(:enquiry, opportunity: opportunity, created_at: Date.new(2015, 9, 15))

    create(:enquiry_response, enquiry: enquiry, created_at: Date.new(2015, 9, 15))

    login_as(create(:editor, service_provider: nassau))
    Timecop.freeze(Date.new(2015, 10, 1)) do
      visit '/export-opportunities/admin/stats'

      select '2015', from: 'stats_from_year'
      select '09', from: 'stats_from_month'
      select '15', from: 'stats_from_day'

      select '2015', from: 'stats_to_year'
      select '09', from: 'stats_to_month'
      select '15', from: 'stats_to_day'

      choose 'granularity', option: 'Universe'

      uncheck('Third party')

      click_on(@content['submit_button'], match: :first)
    end

    expect_opportunities_published('2')
    expect_enquiries('2')
    expect_enquiry_responses('1')
  end

  scenario 'for all the third party universe' do
    region = create(:region, name: 'Latin America')
    another_region = create(:region, name: 'North America')
    country = create(:country, name: 'Mexico', region: region)
    another_country = create(:country, name: 'Barbados', region: another_region)
    nassau = create(:service_provider, name: 'Nassau', country: country)
    mexico = create(:service_provider, name: 'Mexico', country: country)
    barbados = create(:service_provider, name: 'Barbados', country: another_country)

    create(:opportunity, :published, service_provider: nassau, first_published_at: Date.new(2015, 9, 15), source: :post)
    create(:opportunity, :published, service_provider: mexico, first_published_at: Date.new(2015, 9, 15), source: :post)
    create(:opportunity, :published, service_provider: barbados, first_published_at: Date.new(2015, 9, 15), source: :volume_opps)

    login_as(create(:editor, service_provider: nassau))
    Timecop.freeze(Date.new(2015, 10, 1)) do
      visit '/export-opportunities/admin/stats'

      select '2015', from: 'stats_from_year'
      select '09', from: 'stats_from_month'
      select '15', from: 'stats_from_day'
      select '2015', from: 'stats_to_year'
      select '09', from: 'stats_to_month'
      select '15', from: 'stats_to_day'

      choose 'granularity', option: 'Universe'

      uncheck('DBT')

      click_on(@content['submit_button'], match: :first)
    end
page.body
    expect_opportunities_published('1')
    expect_enquiries('0')
    expect_enquiry_responses('0')
  end

  scenario 'for all service providers' do
    nassau = create(:service_provider, name: 'Nassau')
    mexico = create(:service_provider, name: 'Mexico')

    create(:opportunity, :published, service_provider: nassau, first_published_at: Date.new(2015, 9, 15))
    create(:opportunity, :published, service_provider: mexico, first_published_at: Date.new(2015, 9, 15))

    login_as(create(:editor, service_provider: nassau))
    Timecop.freeze(Date.new(2015, 10, 1)) do
      visit '/export-opportunities/admin/stats'

      select '2015', from: 'stats_from_year'
      select '09', from: 'stats_from_month'
      select '15', from: 'stats_from_day'

      select '2015', from: 'stats_to_year'
      select '09', from: 'stats_to_month'
      select '15', from: 'stats_to_day'

      choose 'granularity', option: 'Universe'

      click_on(@content['submit_button'], match: :first)
    end

    expect_opportunities_published('2')
  end

  # Helper methods

  def expect_opportunities_submitted(text)
    expect(page).to have_content(@content['stats_opportunities_submitted'])
    expect(find('.opportunities-submitted .number')).to have_text(text)
  end

  def expect_opportunities_published(text)
    expect(page).to have_content(@content['stats_opportunities_published'])
    expect(find('.opportunities-published .number')).to have_text(text)
  end

  def expect_enquiries(text)
    expect(page).to have_content(@content['stats_enquiries'])
    expect(find('.enquiries .number')).to have_text(text)
  end

  def expect_enquiry_responses(text)
    expect(page).to have_content(@content['stats_enquiry_responses'])
    expect(find('.enquiry-responses .number')).to have_text(text)
  end

  def expect_age_when_published(text)
    expect(page).to have_content(@content['stats_age_when_published'])
    expect(find('.age-when-published .number')).to have_text(text)
  end
end
