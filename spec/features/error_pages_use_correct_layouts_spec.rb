require 'rails_helper'

feature 'error pages use correct layouts' do
  scenario 'admin 404 page' do
    admin = create(:admin)
    login_as(admin)

    visit '/admin/seriously-this-page-cannot-exist'

    expect(page).to have_http_status(:not_found)
    expect(page).to have_content('EIG Opportunities')
    expect(page).to have_content('Sorry, page not found')
    expect(page).to have_css('header.with-proposition')
  end

  scenario 'public 404 page' do
    visit '/seriously-this-page-cannot-exist'
    expect(page).to have_http_status(:not_found)
    expect(page).to have_content('Sorry, page not found')
    expect(page).to have_css('header .nav-intro')
  end
end
