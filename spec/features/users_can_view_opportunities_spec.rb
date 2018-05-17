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
end
