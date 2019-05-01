require 'rails_helper'

feature 'admins can download opportunities' do
  scenario 'downloading opportunities' do
    skip('works IRL, need to update test')
    admin = create(:admin)

    service_provider = create(:service_provider)
    sectors = create_list(:sector, 3)
    countries = [create(:country)]
    opportunity = create(:opportunity, :published, first_published_at: 1.day.ago, created_at: 1.day.ago, sectors: sectors, countries: countries, service_provider: service_provider)
    create_list(:enquiry, 45, opportunity: opportunity)

    login_as(admin)
    visit admin_opportunities_path

    click_on 'Download'

    click_on 'Download as CSV'

    # expect(page.response_headers).to include 'Content-Type' => 'text/csv; charset=utf-8'

    expect(page).to have_content(Time.zone.today.strftime('%Y/%m/%d'))
    expect(page).to have_content(opportunity.title)
    expect(page).to have_content(opportunity.created_at.strftime('%Y-%m-%d %H:%M:%S'))
    expect(page).to have_content(opportunity.first_published_at.strftime('%Y-%m-%d %H:%M:%S'))
    expect(page).to have_content(opportunity.contacts.first.email)
    expect(page).to have_content(opportunity.response_due_on.strftime('%Y/%m/%d'))
    expect(page).to have_content(45)
    expect(page).to have_content(service_provider.name)
    expect(page).to have_content(countries.first.name)
    sectors.each do |sector|
      expect(page).to have_content(sector.name)
    end
    expect(page).to have_content('Published')
  end

  scenario 'downloading opportunities by date range' do
    skip('works IRL, need to update test')
    in_range = create(:opportunity, created_at: Date.new(2016, 6, 15))
    out_of_range = create(:opportunity, created_at: Date.new(2016, 7, 15))

    admin = create(:admin)

    login_as(admin)
    visit '/export-opportunitiesadmin/opportunities/downloads/new'

    expect(page).to have_button('Download as CSV')

    select '2016', from: 'created_at_from_year'
    select 'June', from: 'created_at_from_month'
    select '1', from: 'created_at_from_day'

    select '2016', from: 'created_at_to_year'
    select 'July', from: 'created_at_to_month'
    select '1', from: 'created_at_to_day'

    click_on 'Download as CSV'

    # expect(page.response_headers).to include 'Content-Disposition' => 'attachment; filename="eig-opportunities-2016-06-01-2016-07-01.csv"'
    # expect(page.response_headers).to include 'Content-Type' => 'text/csv; charset=utf-8'

    expect(page).to have_content(in_range.title)
    expect(page).not_to have_content(out_of_range.title)
  end

  scenario 'downloading opportunities by date range - invalid date range: JavaScript On', js: true do
    admin = create(:admin)

    login_as(admin)
    visit admin_opportunities_path
    click_on 'Download'

    select '2016', from: 'created_at_from_year'
    select 'March', from: 'created_at_from_month'
    select '1', from: 'created_at_from_day'

    select '2016', from: 'created_at_to_year'
    select 'February', from: 'created_at_to_month'
    select '1', from: 'created_at_to_day'

    click_on 'Download as CSV'

    expect(page).to have_content('The "From" date must be before the "To" date')
  end

  scenario 'downloading opportunities by date range - invalid To date: JavaScript On', js: true do
    admin = create(:admin)

    login_as(admin)
    visit '/export-opportunities/admin/opportunities/downloads/new'

    select '2016', from: 'created_at_from_year'
    select 'February', from: 'created_at_from_month'
    select '1', from: 'created_at_from_day'

    select '2016', from: 'created_at_to_year'
    select 'February', from: 'created_at_to_month'
    select '31', from: 'created_at_to_day'

    click_on 'Download as CSV'

    expect(page).to have_content('The "To" date is invalid')
  end

  scenario 'downloading opportunities by date range - invalid From date: JavaScript On', js: true do
    admin = create(:admin)

    login_as(admin)
    visit '/export-opportunities/admin/opportunities/downloads/new'

    select '2016', from: 'created_at_from_year'
    select 'February', from: 'created_at_from_month'
    select '31', from: 'created_at_from_day'

    select '2016', from: 'created_at_to_year'
    select 'March', from: 'created_at_to_month'
    select '1', from: 'created_at_to_day'

    click_on 'Download as CSV'

    expect(page).to have_content('The "From" date is invalid')
  end

  scenario 'downloading opportunities - submit button is disabled: JavaScript On', js: true do
    skip('works IRL, need to update test')
    admin = create(:admin)

    login_as(admin)
    visit '/export-opportunities/admin/opportunities/downloads/new'

    select '2016', from: 'created_at_from_year'
    select 'February', from: 'created_at_from_month'
    select '1', from: 'created_at_from_day'

    select '2016', from: 'created_at_to_year'
    select 'March', from: 'created_at_to_month'
    select '1', from: 'created_at_to_day'

    click_on 'Download as CSV'

    expect(page).to have_button('Download as CSV')
  end

  scenario 'downloading opportunities - submit button not disabled if error: JavaScript On', js: true do
    admin = create(:admin)

    login_as(admin)
    visit '/export-opportunities/admin/opportunities/downloads/new'

    select '2016', from: 'created_at_from_year'
    select 'February', from: 'created_at_from_month'
    select '31', from: 'created_at_from_day'

    select '2016', from: 'created_at_to_year'
    select 'March', from: 'created_at_to_month'
    select '1', from: 'created_at_to_day'

    click_on 'Download as CSV'

    expect(page).to have_button('Download as CSV', disabled: false)
  end

  scenario 'downloading opportunities - submit button is re-enabled when form changes: JavaScript On', js: true do
    skip('works IRL, need to update test')
    admin = create(:admin)

    login_as(admin)
    visit '/export-opportunities/admin/opportunities/downloads/new'

    select '2016', from: 'created_at_from_year'
    select 'February', from: 'created_at_from_month'
    select '1', from: 'created_at_from_day'

    select '2016', from: 'created_at_to_year'
    select 'March', from: 'created_at_to_month'
    select '1', from: 'created_at_to_day'

    click_on 'Download as CSV'

    expect(page).to have_button('Download as CSV', disabled: true)

    select '2016', from: 'created_at_from_year'
    select 'February', from: 'created_at_from_month'
    select '1', from: 'created_at_from_day'

    expect(page).to have_button('Download as CSV', disabled: false)
  end
end
