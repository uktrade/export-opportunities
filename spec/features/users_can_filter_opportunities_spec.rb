require 'rails_helper'

feature 'Filtering opportunities', :elasticsearch, :commit, js: true do
  scenario 'users can filter opportunities by sector' do
    sector = create(:sector, name: 'Airports')
    opportunity = create(:opportunity, :published)
    opportunity_with_sector = create(:opportunity, :published, sectors: [sector])
    stub_request(:get, '/ditelasticsearch.com/').to_return(status: 200, body: JSON.generate(create_elastic_search_opportunity(_source: { sectors: [slug: sector.slug] })))
    sleep 1
    visit opportunities_path

    within('.filters') do
      find('.js-toggler').click
      select 'Airports', from: 'sectors[]', visible: false
      page.find('.filters__searchbutton').click
    end

    expect(page).to have_content opportunity_with_sector.title
    expect(page).to have_no_content opportunity.title
    expect(page).to have_selector('.results__item', count: 1)
  end

  scenario 'users can filter opportunities by market' do
    country = create(:country, name: 'Iran')
    opportunity = create(:opportunity, :published)
    opportunity_with_market = create(:opportunity, :published, countries: [country])

    sleep 1
    visit opportunities_path

    within('.filters') do
      find('.js-toggler').click
      select 'Iran', from: 'countries[]', visible: false
      page.find('.filters__searchbutton').click
    end

    expect(page).to have_content opportunity_with_market.title
    expect(page).to have_no_content opportunity.title
    expect(page).to have_selector('.results__item', count: 1)
  end

  scenario 'users can filter opportunities by an updated market' do
    country = create(:country, name: 'Iran')
    another_country = create(:country, name: 'Italy')
    opportunity = create(:opportunity, :published)
    opportunity_with_market = create(:opportunity, :published, countries: [country])

    sleep 1
    visit opportunities_path

    within('.filters') do
      find('.js-toggler').click
      select 'Iran', from: 'countries[]', visible: false
      page.find('.filters__searchbutton').click
    end

    expect(page).to have_content opportunity_with_market.title
    expect(page).to have_no_content opportunity.title
    expect(page).to have_selector('.results__item', count: 1)

    opportunity_with_market.countries = [another_country]
    opportunity_with_market.save!

    sleep 1
    visit opportunities_path

    within('.filters') do
      find('.js-toggler').click
      select 'Italy', from: 'countries[]', visible: false
      page.find('.filters__searchbutton').click
    end

    expect(page).to have_content opportunity_with_market.title
    expect(page).to have_no_content opportunity.title
    expect(page).to have_selector('.results__item', count: 1)
  end

  scenario 'users can filter opportunities by type' do
    type = create(:type, name: 'Aid Funded Business')
    opportunity = create(:opportunity, :published)
    opportunity_with_type = create(:opportunity, :published, types: [type])

    sleep 1
    visit opportunities_path

    within('.filters') do
      find('.js-toggler').click
      select 'Aid Funded Business', from: 'types', visible: false
      page.find('.filters__searchbutton').click
    end

    expect(page).to have_content opportunity_with_type.title
    expect(page).to have_no_content opportunity.title
  end

  scenario 'users can filter opportunity that belongs to multiple markets' do
    country = create(:country, name: 'Iran')
    another_country = create(:country, name: 'Italy')
    opportunity_with_market = create(:opportunity, :published, countries: [country, another_country])

    sleep 1
    visit opportunities_path

    within('.filters') do
      find('.js-toggler').click
      select 'Iran', from: 'countries[]', visible: false
      page.find('.filters__searchbutton').click
    end

    expect(page).to have_content opportunity_with_market.title
    expect(page).to have_selector('.results__item', count: 1)

    visit opportunities_path

    within('.filters') do
      find('.js-toggler').click
      select 'Italy', from: 'countries[]', visible: false
      page.find('.filters__searchbutton').click
    end

    expect(page).to have_content opportunity_with_market.title
    expect(page).to have_selector('.results__item', count: 1)
  end

  scenario 'users can filter opportunity that belongs to multiple types' do
    type = create(:type, name: 'Aid Funded Business')
    another_type = create(:type, name: 'Private Sector')
    opportunity_with_market = create(:opportunity, :published, types: [type, another_type])

    sleep 1
    visit opportunities_path

    within('.filters') do
      find('.js-toggler').click
      select 'Aid Funded Business', from: 'types', visible: false
      page.find('.filters__searchbutton').click
    end

    expect(page).to have_content opportunity_with_market.title
    expect(page).to have_selector('.results__item', count: 1)

    visit opportunities_path

    within('.filters') do
      find('.js-toggler').click
      select 'Private Sector', from: 'types', visible: false
      page.find('.filters__searchbutton').click
    end

    expect(page).to have_content opportunity_with_market.title
    expect(page).to have_selector('.results__item', count: 1)
  end

  scenario 'users can filter by multiple categories' do
    country = create(:country)
    sector = create(:sector)
    create(:opportunity, status: 'publish', countries: [country])
    create(:opportunity, status: 'publish', sectors: [sector])
    create(:opportunity, status: 'publish', countries: [country], sectors: [sector])

    sleep 1
    visit(opportunities_path)

    expect(page).to have_content 'Find and apply'
    expect(page).to have_no_selector('.results__item')

    within('.filters') do
      select country.name, from: 'countries[]', visible: false
      page.find('.filters__searchbutton').click
    end

    expect(page).to have_selector('.results__item', count: 2)

    within('.filters') do
      select sector.name, from: 'sectors[]', visible: false
      page.find('.filters__searchbutton').click
    end

    expect(page).to have_selector('.results__item', count: 1)
  end

  scenario 'users can use filters and then paginate through results' do
    allow(Opportunity).to receive(:default_per_page).and_return(10)
    country1 = create(:country, name: 'Selected 1')
    create_list(:opportunity, 8, status: 'publish', countries: [country1])
    country2 = create(:country, name: 'Selected 2')
    create_list(:opportunity, 8, status: 'publish', countries: [country2])
    ignored_country = create(:country, name: 'Not Selected')
    create_list(:opportunity, 4, status: 'publish', countries: [ignored_country])

    sleep 1

    visit(opportunities_path)

    within('.filters') do
      select country1.name, from: 'countries[]', visible: false
      page.find('.filters__searchbutton').click
    end

    within('.filters') do
      select country2.name, from: 'countries[]', visible: false
      page.find('.filters__searchbutton').click
    end

    page.find('#pager').click_on('2')

    expect(page.find('.results')).to have_selector('.results__item', count: 6)
  end
end
