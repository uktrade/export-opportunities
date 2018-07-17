require 'rails_helper'

feature 'Filtering opportunities', :elasticsearch, :commit do
  scenario 'users can filter opportunities by market' do
    country = create(:country, name: 'Iran')
    opportunity = create(:opportunity, :published)
    opportunity_with_market = create(:opportunity, :published, countries: [country])

    sleep 1
    visit opportunities_path

    expect(page).to have_content 'Iran (1)'

    page.find("#countries_0").click
    page.find('.button.submit').click

    expect(page).to have_content opportunity_with_market.title
    expect(page).to have_no_content opportunity.title
  end

  scenario 'users can filter opportunities by an updated market' do
    country = create(:country, name: 'Iran')
    another_country = create(:country, name: 'Italy')
    opportunity = create(:opportunity, :published)
    opportunity_with_market = create(:opportunity, :published, countries: [country])

    sleep 1
    visit opportunities_path

    # select Iran
    page.find("#countries_0").click
    page.find('.button.submit').click

    expect(page).to have_content('1 result found for all opportunities  in Iran')

    expect(page).to have_content opportunity_with_market.title
    expect(page).to have_no_content opportunity.title

    opportunity_with_market.countries = [another_country]
    opportunity_with_market.save!

    sleep 1
    visit opportunities_path

    # select Italy
    page.find("#countries_0").click
    page.find('.button.submit').click
    search_results_information = page.find(:css, '#opportunity-search-results').text

    expect(page).to have_content opportunity_with_market.title
    expect(page).to have_no_content opportunity.title
    expect(page).to have_content('1 result found for all opportunities  in Italy')
  end

  scenario 'users can filter opportunity that belongs to multiple markets' do
    country = create(:country, name: 'Iran')
    another_country = create(:country, name: 'Italy')
    opportunity_with_market = create(:opportunity, :published, countries: [country, another_country])

    sleep 1
    visit opportunities_path

    # select Iran
    page.find("#countries_0").click
    page.find('.button.submit').click
    search_results_information = page.find(:css, '#opportunity-search-results').text

    expect(page).to have_content opportunity_with_market.title

    expect(page).to have_content('1 result found for all opportunities  in Iran')

    visit opportunities_path

    # select Italy
    page.find("#countries_1").click
    page.find('.button.submit').click
    search_results_information = page.find(:css, '#opportunity-search-results').text

    expect(page).to have_content opportunity_with_market.title
    expect(page).to have_content('1 result found for all opportunities  in Italy')
  end

  scenario 'users can filter by multiple categories' do
    skip('TODO: refactor with countries and industries when we have industries')
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

    visit opportunities_path

    # select selected 1
    page.find("#countries_1").click

    # select selected 2
    page.find("#countries_2").click

    # update results
    page.find('.button.submit').click

    # click next link to go to 2nd page
    click_link('Next')

    expect(page.body).to include('Displaying items <b>11&nbsp;-&nbsp;16</b> of <b>16</b> in total')
  end
end
