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
end
