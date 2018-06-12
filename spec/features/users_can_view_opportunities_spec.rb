require 'rails_helper'

RSpec.feature 'User can view opportunities in list', :elasticsearch, :commit do
  scenario 'navigates to root', :elasticsearch, :commit do
    visit '/'

    expect(page).to have_content('Latest export opportunities')
  end

  scenario 'clicks on view more opportunities from root', :elasticsearch, :commit do
    country1 = create(:country, name: 'Selected 1')
    create_list(:opportunity, 6, status: 'publish', countries: [country1])

    visit '/'

    expect(page).to have_content('Latest export opportunities')
    expect(page).to have_content('View more')

    sleep 1
    click_on 'View more'

    expect(page.body).to have_content('6 results found')
  end

  scenario 'clicks on featured industries link, gets both OO and posts opportunities', :elasticsearch, :commit, js: true do
    sector = create(:sector, slug: 'food-drink', id: 14, name: 'FoodDrink')
    security_sector = create(:sector, slug: 'security', id: 12, name: 'Security')
    security_opp = create(:opportunity, title: 'Italy - White hat hacker required', description: 'security food drink', sectors: [security_sector], source: :post, status: :publish, response_due_on: 1.week.from_now)
    post_opp = create(:opportunity, title: 'France - Cow required', sectors: [sector], source: :post, status: :publish, response_due_on: 1.week.from_now)
    oo_opp = create(:opportunity, title: 'Greece - Pimms food drink in Mykonos', description: 'food drink pimms mykonoos', source: :volume_opps, status: :publish, response_due_on: 1.week.from_now)

    visit root_path

    sleep 1
    click_on 'FoodDrink'

    expect(page).to have_content('Cow required')
    expect(page).to have_content('Pimms food drink in Mykonos')
    expect(page).to_not have_content('Italy')
  end

  scenario 'uses search term only', :elasticsearch, :commit, js: true do
    fictional_country = create(:country, name: 'Zouaziland')
    create(:opportunity, :published, title: 'Boats for Zouaziland lakes', countries: [fictional_country])
    another_fictional_country = create(:country, name: 'Martonia')
    create(:opportunity, :published, title: 'Ships for Martian oceans', countries: [another_fictional_country])

    visit '/'

    sleep 1
    within first('.search-form') do
      fill_in 's', with: 'oceans'
      click_on 'Find opportunities'
    end

    expect(page).to have_content('Martonia')
    expect(page).to_not have_content('Zouaziland')
  end

  scenario 'uses country dropdown only', :elasticsearch, :commit, js: true do
    fictional_country = create(:country, name: 'Zouaziland')
    create(:opportunity, :published, title: 'Boats for Zouaziland lakes', countries: [fictional_country])
    another_fictional_country = create(:country, name: 'Martonia')
    create(:opportunity, :published, title: 'Ships for Martian oceans', countries: [another_fictional_country])

    visit '/'

    sleep 1
    within first('.search-form') do
      select('Zouaziland', from: 'areas[]')
      click_on 'Find opportunities'
    end

    expect(page).to have_content('Zouaziland')
    expect(page).to_not have_content('Martonia')
  end

  scenario 'uses region from country dropdown only', :elasticsearch, :commit, js: true do
    mediterranean_country = create(:country, name: 'Greece', slug: 'greece')
    create(:opportunity, :published, title: 'British pies', countries: [mediterranean_country])
    asian_country = create(:country, name: 'Japan', slug: 'japan')
    create(:opportunity, :published, title: 'British tea', countries: [asian_country])

    visit '/'

    sleep 1
    within first('.search-form') do
      select('Mediterranean Europe', from: 'areas[]')
      click_on 'Find opportunities'
    end

    expect(page).to have_content('pies')
    expect(page).to have_content('Greece')

    expect(page).to_not have_content('tea')
    expect(page).to_not have_content('Japan')
  end

  scenario 'uses search term and country dropdown', :elasticsearch, :commit, js: true do
    fictional_country = create(:country, name: 'Zouaziland')
    create(:opportunity, :published, title: 'Boats for Zouaziland lakes', countries: [fictional_country])
    another_fictional_country = create(:country, name: 'Martonia')
    create(:opportunity, :published, title: 'Ships for Martian oceans', countries: [another_fictional_country])

    visit '/'

    sleep 1
    within first('.search-form') do
      fill_in 's', with: 'lakes'
      select('Zouaziland', from: 'areas[]')
      click_on 'Find opportunities'
    end

    expect(page).to have_content('Zouaziland')
    expect(page).to_not have_content('Martonia')
  end

  scenario 'uses search term and region from country dropdown', :elasticsearch, :commit, js: true do
    mediterranean_country = create(:country, name: 'Greece', slug: 'greece')
    create(:opportunity, :published, title: 'British pies', countries: [mediterranean_country])
    asian_country = create(:country, name: 'Japan', slug: 'japan')
    create(:opportunity, :published, title: 'British tea', countries: [asian_country])

    visit '/'

    sleep 1
    within first('.search-form') do
      fill_in 's', with: 'pies'
      select('Mediterranean Europe', from: 'areas[]')
      click_on 'Find opportunities'
    end

    expect(page).to have_content('pies')
    expect(page).to have_content('Greece')

    expect(page).to_not have_content('tea')
    expect(page).to_not have_content('Japan')
  end

  scenario 'complex scenario of filtering on opportunities. Testing regions, countries and new search in page', :elasticsearch, :commit do
    # start with 2 opportunities in Mediterranean (1 from Greece, 1 from Italy) and 1 in North East Asia(Japan)
    mediterranean_country = create(:country, name: 'Greece', slug: 'greece')
    create(:opportunity, :published, title: 'British pies', countries: [mediterranean_country])
    another_mediterranean_country = create(:country, name: 'Italy', slug: 'italy')
    create(:opportunity, :published, title: 'Olive oil', countries: [another_mediterranean_country])
    asian_country = create(:country, name: 'Japan', slug: 'japan')
    create(:opportunity, :published, title: 'British tea', countries: [asian_country])

    # just get all opportunities
    visit '/'

    sleep 1
    within first('.search-form') do
      click_on 'Find opportunities'
    end

    expect(page).to have_content('pies')
    expect(page).to have_content('oil')
    expect(page).to have_content('tea')

    expect(page).to have_content('Greece')
    expect(page).to have_content('Italy')
    expect(page).to have_content('Japan')

    expect(page).to_not have_content('Spain')
    expect(page).to_not have_content('Kenya')

    # select greece and italy from countries
    find(:css, '#countries_0').set(true)
    find(:css, '#countries_1').set(true)
    click_on 'Update results'

    # only Greek and Italian opportunities should be visible
    expect(page).to have_content('pies')
    expect(page).to have_content('oil')
    expect(page).to_not have_content('tea')

    expect(page).to have_content('Greece')
    expect(page).to have_content('Italy')
    expect(page).to_not have_content('Japan')

    expect(page).to have_content('2 results found in Greece or Italy')

    # only select Greece from countries
    find(:css, '#countries_1').set(false)
    click_on 'Update results'

    # only Greek opportunity should be visible
    expect(page).to have_content('pies')
    expect(page).to_not have_content('oil')
    expect(page).to_not have_content('tea')

    expect(page).to have_content('Greece')
    expect(page).to_not have_content('Italy')
    expect(page).to_not have_content('Japan')

    expect(page).to have_content('1 result found in Greece')

    # select mediterranean region now
    find(:css, '#regions_5').set(true)
    click_on 'Update results'

    # only Greek and Italian(because of Mediterranean Europe) opportunities should be visible
    expect(page).to have_content('pies')
    expect(page).to have_content('oil')
    expect(page).to_not have_content('tea')

    expect(page).to have_content('Greece')
    expect(page).to have_content('Italy')
    expect(page).to_not have_content('Japan')

    expect(page).to have_content('2 results found in Greece or Mediterranean Europe')

    # select North East Asia now
    # 3 results now. 2 results from before + 1 from North Asia
    find(:css, '#regions_10').set(true)
    click_on 'Update results'

    # all opportunities should be visible now
    expect(page).to have_content('pies')
    expect(page).to have_content('oil')
    expect(page).to have_content('tea')

    expect(page).to have_content('Greece')
    expect(page).to have_content('Italy')
    expect(page).to have_content('Japan')

    # shouldn't have other countries in the dropdown list
    expect(page).to_not have_content('Spain')
    expect(page).to_not have_content('Canada')

    expect(page).to have_content('3 results found in Greece or Mediterranean Europe or North East Asia')

    # select a region with no results (North America), nothing should change
    find(:css, '#regions_9').set(true)
    click_on 'Update results'

    expect(page).to_not have_content('Canada')
    expect(page).to have_content('3 results found in Greece or Mediterranean Europe or North America or North East Asia')

    # start a new search by searching for oil on the top right hand corner
    within '.search' do
      fill_in 's', with: 'oil'
      find(:css, '.submit').click
    end

    # only Italian opportunity should be visible, not Greek, not Japanese
    expect(page).to_not have_content('pies')
    expect(page).to have_content('oil')

    expect(page).to_not have_content('Greece')
    expect(page).to have_content('Italy')
  end

  scenario 'clearing filters after we have some results', :elasticsearch, :commit do
    # start with 2 opportunities in Mediterranean (1 from Greece, 1 from Italy) and 1 in North East Asia(Japan)
    mediterranean_country = create(:country, name: 'Greece', slug: 'greece')
    create(:opportunity, :published, title: 'British pies', countries: [mediterranean_country])
    another_mediterranean_country = create(:country, name: 'Italy', slug: 'italy')
    create(:opportunity, :published, title: 'Olive oil', countries: [another_mediterranean_country])
    asian_country = create(:country, name: 'Japan', slug: 'japan')
    create(:opportunity, :published, title: 'British tea', countries: [asian_country])

    visit '/'

    sleep 1
    within first('.search-form') do
      fill_in 's', with: 'British'
      click_on 'Find opportunities'
    end

    # Greek and Japanese opportunities should be visible
    expect(page).to have_content('pies')
    expect(page).to_not have_content('oil')
    expect(page).to have_content('tea')

    expect(page).to have_content('Greece')
    expect(page).to_not have_content('Italy')
    expect(page).to have_content('Japan')

    # Use region filtering to select North East Asia (Japan)
    find(:css, '#regions_10').set(true)
    click_on 'Update results'

    # only Japanese opportunity should be visible
    expect(page).to_not have_content('pies')
    expect(page).to_not have_content('oil')
    expect(page).to have_content('tea')

    expect(page).to_not have_content('Greece')
    expect(page).to_not have_content('Italy')
    expect(page).to have_content('Japan')


    # clear all filters. Can't directly click on the link b/c it has non-ascii character, so we visit the URL with the non-ascii utf8=CHECK_CHARACTER removed
    clear_all_filters = page.find(:css, 'a[href].reset')[:href]
    clear_all_filters_link = clear_all_filters.encode('ascii', undef: :replace, replace: '')

    visit clear_all_filters_link

    # Greek and Japanese opportunities should be visible
    # like they were before filtering
    expect(page).to have_content('pies')
    expect(page).to_not have_content('oil')
    expect(page).to have_content('tea')

    expect(page).to have_content('Greece')
    expect(page).to_not have_content('Italy')
    expect(page).to have_content('Japan')
  end
end
