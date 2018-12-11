require 'rails_helper'

feature 'Searching opportunities with filter', elasticsearch: true do
  scenario 'users can search opportunities filtering by region' do
    country = create(:country, name: 'Ireland', slug: 'ireland')
    opportunity = create(:opportunity, :published)
    opportunity_with_market = create(:opportunity, :published, countries: [country])

    sleep 3
    visit opportunities_path

    # select Western Europe region
    check("Western Europe")

    # update results
    page.find('.button.submit').click

    expect(page).to have_content opportunity_with_market.title
    expect(page).to have_no_content opportunity.title
  end

  scenario 'users can search opportunities filtering by sector' do
    skip('TODO: refactor with countries and industries when we have industries')
    sector = create(:sector, name: 'Airports')
    opportunity = create(:opportunity, :published)
    opportunity_with_sector = create(:opportunity, :published, sectors: [sector])

    sleep 1
    visit opportunities_path

    within('.filters') do
      find('.js-toggler').click
      select 'Airports', from: 'sectors', visible: false
      page.find('.filters__searchbutton').click
    end

    expect(page).to have_content opportunity_with_sector.title
    expect(page).to have_no_content opportunity.title
    expect(page).to have_selector('.results__item', count: 1)
  end

  scenario 'users can search opportunities filtering by multiple criteria' do
    skip('TODO: refactor with countries and industries when we have industries')
    country = create(:country)
    sector = create(:sector)
    create(:opportunity, status: 'publish', countries: [country])
    create(:opportunity, status: 'publish', sectors: [sector])
    create(:opportunity, status: 'publish', countries: [country], sectors: [sector])

    sleep 1
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
