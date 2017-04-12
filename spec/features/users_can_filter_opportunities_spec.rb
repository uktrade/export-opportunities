require 'rails_helper'

feature 'Filtering opportunities', js: true do
  scenario 'users can filter opportunities by sector' do
    sector = create(:sector, name: 'Airports')
    opportunity = create(:opportunity, :published)
    opportunity_with_sector = create(:opportunity, :published, sectors: [sector])

    visit opportunities_path

    within('.filters') do
      click_on 'Airports'
    end

    expect(page).to have_content opportunity_with_sector.title
    expect(page).to have_no_content opportunity.title
    expect(page).to have_selector('.opportunities__item', count: 1)
  end

  scenario 'users can filter opportunities by market' do
    country = create(:country, name: 'Iran')
    opportunity = create(:opportunity, :published)
    opportunity_with_market = create(:opportunity, :published, countries: [country])

    visit opportunities_path

    within('.filters') do
      click_on 'Iran'
    end

    expect(page).to have_content opportunity_with_market.title
    expect(page).to have_no_content opportunity.title
    expect(page).to have_selector('.opportunities__item', count: 1)
  end

  scenario 'users can filter opportunities by type' do
    type = create(:type, name: 'Aid Funded Business')
    opportunity = create(:opportunity, :published)
    opportunity_with_type = create(:opportunity, :published, types: [type])

    visit opportunities_path

    within('.filters') do
      click_on 'Aid Funded Business'
    end

    expect(page).to have_content opportunity_with_type.title
    expect(page).to have_no_content opportunity.title
  end

  scenario 'users can filter by multiple categories' do
    country = create(:country)
    sector = create(:sector)
    create(:opportunity, status: 'publish', countries: [country])
    create(:opportunity, status: 'publish', sectors: [sector])
    create(:opportunity, status: 'publish', countries: [country], sectors: [sector])

    visit(opportunities_path)
    expect(page).to have_selector('.opportunities__item', count: 3)
    page.find('a[data-term=' + country.slug + ']').trigger('click')
    expect(page).to have_selector('.opportunities__item', count: 2)
    page.find('a[data-term=' + sector.slug + ']').click
    expect(page).to have_selector('.opportunities__item', count: 1)
  end

  scenario 'users can use filters and then paginate through results' do
    allow(Opportunity).to receive(:default_per_page).and_return(10)
    country1 = create(:country, name: 'Selected 1')
    create_list(:opportunity, 8, status: 'publish', countries: [country1])
    country2 = create(:country, name: 'Selected 2')
    create_list(:opportunity, 8, status: 'publish', countries: [country2])
    ignored_country = create(:country, name: 'Not Selected')
    create_list(:opportunity, 4, status: 'publish', countries: [ignored_country])

    visit(opportunities_path)

    page.find('.filters').click_on(country1.name)
    wait_for_ajax
    page.find('.filters').click_on(country2.name)
    wait_for_ajax

    page.find('#pager').click_on('2')
    wait_for_ajax

    expect(page.find('.opportunities')).to have_selector('.opportunities__item', count: 6)
  end
end
