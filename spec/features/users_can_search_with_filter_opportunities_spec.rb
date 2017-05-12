require 'rails_helper'

feature 'Searching opportunities with filter', js: true do
  scenario 'users can search opportunities filtering by region' do
    country = create(:country, name: 'Ireland')
    opportunity = create(:opportunity, :published)
    opportunity_with_market = create(:opportunity, :published, countries: [country])

    visit opportunities_path

    within('.filters') do
      find('.js-toggler').click
      select 'Ireland', from: 'countries[]', visible: false
      page.find('.filters__searchbutton').click
    end

    expect(page).to have_content opportunity_with_market.title
    expect(page).to have_no_content opportunity.title
    expect(page).to have_selector('.results__item', count: 1)
  end

  scenario 'users can search opportunities filtering by sector' do
    sector = create(:sector, name: 'Airports')
    opportunity = create(:opportunity, :published)
    opportunity_with_sector = create(:opportunity, :published, sectors: [sector])

    visit opportunities_path

    within('.filters') do
      find('.js-toggler').click
      select 'Airports', from: 'sectors', visible: false
      page.find('.filters__searchbutton').click
    end

    save_and_open_page

    expect(page).to have_content opportunity_with_sector.title
    expect(page).to have_no_content opportunity.title
    expect(page).to have_selector('.results__item', count: 1)
  end

  scenario 'users can search opportunities filtering by value' do
    value = create(:value, name: '10K')
    opportunity = create(:opportunity, :published)
    opportunity_with_value = create(:opportunity, :published, values: [value])

    visit opportunities_path

    within('.filters') do
      find('.js-toggler').click
      select '10K', from: 'values', visible: false
      page.find('.filters__searchbutton').click
    end

    expect(page).to have_content opportunity_with_value.title
    expect(page).to have_no_content opportunity.title
    expect(page).to have_selector('.results__item', count: 1)
  end

  scenario 'users can search opportunities filtering by value' do
    type = create(:type, name: 'Aid Funded Business')
    opportunity = create(:opportunity, :published)
    opportunity_with_type = create(:opportunity, :published, types: [type])

    visit opportunities_path

    within('.filters') do
      find('.js-toggler').click
      select 'Aid Funded Business', from: 'types', visible: false
      page.find('.filters__searchbutton').click
    end

    expect(page).to have_content opportunity_with_type.title
    expect(page).to have_no_content opportunity.title
    expect(page).to have_selector('.results__item', count: 1)
  end

  scenario 'users can search opportunities filtering by multiple criteria' do
    country = create(:country)
    sector = create(:sector)
    create(:opportunity, status: 'publish', countries: [country])
    create(:opportunity, status: 'publish', sectors: [sector])
    create(:opportunity, status: 'publish', countries: [country], sectors: [sector])

    visit opportunities_path

    within('.filters') do
      find('.js-toggler').click
      find('.filters__groupA div.filters__item:nth-child(2) input.select2-search__field').set(country.name + "\n")
      find('.filters__groupB div.filters__item:nth-of-type(1) input.select2-search__field').set(sector.name + "\n")
      select country.name, from: 'countries', visible: false
      select sector.name, from: 'sectors', visible: false
      page.find('.filters__searchbutton').click
    end

    expect(page).to have_selector('.results__item', count: 1)
  end
end
