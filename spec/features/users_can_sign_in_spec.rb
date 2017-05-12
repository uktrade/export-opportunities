require 'rails_helper'

feature 'Signing in as a user', :elasticsearch do
  scenario 'Signing in via the old /sign_in path' do
    mock_sso_with(email: 'email@example.com')

    visit '/sign_in'

    expect(page).to have_link 'Sign out'
  end

  scenario 'Signed in user visits /' do
    mock_sso_with(email: 'email@example.com')
    visit '/sign_in'
    visit '/'

    expect(page).to have_content 'Find and apply'
  end

  scenario 'Signing in successfully' do
    mock_sso_with(email: 'email@example.com')

    visit '/dashboard'

    expect(page).to have_flash_message 'You are now signed in'
  end

  scenario 'Signing in successfully, overwriting an existing stub user' do
    create(:user, uid: nil, provider: nil, email: 'stub@example.com')

    mock_sso_with(email: 'stub@example.com')

    visit '/dashboard'

    expect(page).to have_flash_message 'You are now signed in'
  end

  scenario 'Signing out', skip: true do
    mock_sso_with(email: 'email@example.com')

    visit '/dashboard'

    expect(page).to have_flash_message 'You are now signed in'

    within 'ul.nav-intro' do
      click_link 'Sign out'
    end

    expect(page).to have_no_link 'Sign out'
  end
end
