require 'rails_helper'

RSpec.feature 'User can view opportunities in list' do

  scenario 'navigates to root', :elasticsearch, :commit do
    opp = create(:opportunity, title: 'France - Cow required')
    user = create(:user, email: 'test@example.com')
    enquiry = create(:enquiry, opportunity: opp, user: user)

    visit '/'

    expect(page).to have_content('Find business opportunities')
  end

  scenario 'clicks on view more opportunities from root', :elasticsearch, :commit do
    country1 = create(:country, name: 'Selected 1')
    create_list(:opportunity, 6, status: 'publish', countries: [country1])

    visit '/'

    expect(page).to have_content('Find business opportunities')
    expect(page).to have_content('View more')

    sleep 1
    click_on 'View more'

    expect(page.body).to have_content('6 results found')
  end

  scenario 'clicks on featured industries link, gets both OO and posts opportunities', :elasticsearch, :commit do
    sector = create(:sector, slug: 'food-drink', id: 14, name: 'FoodDrink')
    security_sector = create(:sector, slug: 'security', id: 12, name: 'Security')
    security_opp = create(:opportunity, title: 'Italy - White hat hacker required', description: 'security food drink', sectors: [security_sector], source: :post, status: :publish, response_due_on: 1.week.from_now)
    post_opp = create(:opportunity, title: 'France - Cow required', sectors: [sector], source: :post, status: :publish, response_due_on: 1.week.from_now)
    oo_opp = create(:opportunity, title: 'Greece - Pimms food drink in Mykonos', description: 'food drink pimms mykonoos', source: :volume_opps, status: :publish, response_due_on: 1.week.from_now)

    visit root_path

    click_on 'FoodDrink'

    expect(page).to have_content('Cow required')
    expect(page).to have_content('Pimms food drink in Mykonos')
    expect(page).to_not have_content('Italy')
  end
end
