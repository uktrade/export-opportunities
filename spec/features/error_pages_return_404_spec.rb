require 'rails_helper'

feature 'non-existing pages return 404 with an error message' do
  scenario 'admin 404 page' do
    admin = create(:admin)
    login_as(admin)

    visit '/export-opportunities/admin/seriously-this-page-cannot-exist'

    expect(page).to have_http_status(:not_found)
    expect(page).to have_content('This page cannot be found')
  end

  scenario 'public 404 page' do
    visit '/export-opportunities/seriously-this-page-cannot-exist'
    expect(page).to have_http_status(:not_found)
    expect(page).to have_content('This page cannot be found')
  end
end
