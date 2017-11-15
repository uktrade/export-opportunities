require 'rails_helper'

feature 'Logging in as an editor' do
  scenario 'Unauthenticated editor' do
    visit admin_opportunities_path
    expect_editor_to_be_logged_out
  end

  scenario 'Confirmed editor' do
    create(:editor, email: 'email@example.com', password: 'wibble-sidecar-sling')

    visit new_editor_session_path

    within '#new_editor' do
      fill_in 'Email',    with: 'email@example.com'
      fill_in 'Password', with: 'wibble-sidecar-sling'
      click_on 'Log in'
    end

    expect_editor_to_be_logged_in
  end

  scenario 'Unconfirmed editor' do
    create(:editor, email: 'email@example.com', password: 'gobbledegook', confirmed_at: nil)

    visit new_editor_session_path

    within '#new_editor' do
      fill_in 'Email',    with: 'email@example.com'
      fill_in 'Password', with: 'gobbledegook'
      click_on 'Log in'
    end

    expect_editor_to_be_logged_out
  end

  scenario 'Deactivated editor' do
    create(:editor, email: 'email@example.com', password: 'gobbledegook', deactivated_at: 1.day.ago)

    visit new_editor_session_path

    within '#new_editor' do
      fill_in 'Email',    with: 'email@example.com'
      fill_in 'Password', with: 'gobbledegook'
      click_on 'Log in'
    end

    expect_editor_to_be_logged_out
  end

  scenario 'Editor with bad password hash' do
    editor = create(:editor, email: 'email@example.com')
    editor.update_column(:encrypted_password, 'invalid-hash')

    visit new_editor_session_path

    within '#new_editor' do
      fill_in 'Email', with: 'email@example.com'
      fill_in 'Password', with: 'gobbledegook'
      click_on 'Log in'
    end

    expect_editor_to_be_logged_out
  end

  context 'Accepting an invitation' do
    background do
      @editor = create(:editor,
        email: 'email@example.com',
        confirmed_at: nil,
        confirmation_token: SecureRandom.hex(32),
        confirmation_sent_at: 1.hour.ago)

      visit admin_update_editor_confirmation_url(confirmation_token: @editor.confirmation_token)
    end

    scenario 'setting a password' do
      password = SecureRandom.hex(32)
      fill_in 'Password', with: password
      fill_in 'Password confirmation', with: password
      click_on 'Set my password'

      expect(page.current_path).to eq(admin_opportunities_path)
      expect(page).to have_content 'Your email address has been successfully confirmed.'
    end

    scenario 'attempting to set a weak password' do
      password = 'password1234'
      fill_in 'Password', with: password
      fill_in 'Password confirmation', with: password
      click_on 'Set my password'

      within '#error_explanation' do
        expect(page).to have_content I18n.t('errors.guessable_password')
      end

      expect(@editor.reload.confirmed_at).to be_nil
    end
  end

  scenario 'user signing in from multiple browsers' do
    admin = create(:admin)

    in_browser(:one) do
      login_as(admin)

      visit '/admin/opportunities'
      expect(page).to have_content('Opportunities')
    end

    in_browser(:two) do
      login_as(admin)

      visit '/admin/enquiries'
      expect(page).to have_content('Enquiries')
    end

    in_browser(:one) do
      # devise_security_extensions should log out the first user's session.
      visit '/admin/enquiries'

      expect(page).to have_content('Your login credentials were used in another browser. Please sign in again to continue in this browser.')
      expect(page).to_not have_content('opportunities')
    end
  end
end

private

def expect_editor_to_be_logged_in
  expect(page).to have_text(logged_in_text)
  expect(page).to have_selector(:link_or_button, log_out_button_text)
end

def expect_editor_to_be_logged_out
  expect(page).to have_no_text(logged_in_text)
  expect(page).to have_no_selector(:link_or_button, log_out_button_text)
end

def log_out_button_text
  'Log out'
end

def logged_in_text
  'Title'
end

def in_browser(name)
  old_session = Capybara.session_name

  Capybara.session_name = name
  yield

  Capybara.session_name = old_session
end
