require 'rails_helper'

feature 'Signing in as a user', :elasticsearch, sso: true do

  scenario 'Signing in via the old /sign_in path' do
    mock_sso_with(email: 'email@example.com')

    visit '/export-opportunities/sign_in'

    expect(page).to have_link 'Sign out'
  end

  scenario 'Signed in user visits /', :elasticsearch, :commit do
    create(:opportunity, :published, title: 'Food')
    mock_sso_with(email: 'email@example.com')
    visit '/export-opportunities/sign_in'
    visit '/export-opportunities/'

    expect(page).to have_content 'Find export opportunities'
  end

  scenario 'Signing in successfully' do
    mock_sso_with(email: 'email@example.com')

    visit '/export-opportunities/dashboard'

    expect(page).to have_flash_message 'You are now signed in'
  end

  scenario 'Signing in successfully, overwriting an existing stub user' do
    create(:user, uid: nil, provider: nil, email: 'stub@example.com')

    mock_sso_with(email: 'stub@example.com')

    visit '/export-opportunities/dashboard'

    expect(page).to have_flash_message 'You are now signed in'
  end

  scenario 'Signing out' do
    mock_sso_with(email: 'email@example.com')

    visit '/export-opportunities/dashboard'

    expect(page).to have_flash_message 'You are now signed in'
    
    visit '/export-opportunities/sign_out'

    expect(page).to have_no_link 'Sign out'
  end
end
