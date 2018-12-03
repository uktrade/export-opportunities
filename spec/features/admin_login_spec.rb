require 'rails_helper'
require 'capybara/email/rspec'

feature 'Logging in as an admin' do
  scenario 'Unauthenticated editor' do
    visit admin_opportunities_path
    expect_editor_to_be_logged_out
  end

  scenario 'Unauthenticated editor visits help and enquiries pages' do
    visit '/admin/help/how-to-write-an-export-opportunity/overview'
    expect_editor_to_be_logged_out
    expect(page).to_not have_text('This page cannot be found')
    expect(page).to have_text('Log in')
  end

  scenario 'Logging in successfully' do
    create(:editor, email: 'email@example.com', password: 'wibble-sidecar-sling')

    visit new_editor_session_path

    within '#new_editor' do
      fill_in 'Email',    with: 'email@example.com'
      fill_in 'Password', with: 'wibble-sidecar-sling'
      click_on 'Log in'
    end

    expect_editor_to_be_logged_in
  end

  scenario 'Logging in successfully to help guide' do
    create(:editor, email: 'email@example.com', password: 'wibble-sidecar-sling')

    visit '/admin/help/how-to-write-an-export-opportunity/overview'

    within '#new_editor' do
      fill_in 'Email',    with: 'email@example.com'
      fill_in 'Password', with: 'wibble-sidecar-sling'
      click_on 'Log in'
    end

    expect(page.current_url).to include('/admin/help')
  end

  scenario 'visiting admin help guide for opportunities' do
    editor = create(:editor)
    login_as(editor)

    visit '/admin/help/how-to-write-an-export-opportunity/overview'

    expect(page.body).to include('This guidance will help you write export opportunities.')
    expect(page.body).to include('How to write an export opportunity')
  end

  scenario 'visiting admin help guide for enquiries' do
    editor = create(:editor)
    login_as(editor)

    visit '/admin/help/how-to-assess-a-company/overview'

    # we are logged in but can't see the Log out option without js.
    expect(page).to have_content('Opportunities Enquiries Stats')
    expect(page).to have_content('You will need to assess whether a company is both eligible and suitable')
  end

  scenario 'visiting admin old sign in page after we have signed in' do
    editor = create(:editor)
    login_as(editor)

    visit '/admin/help/how-to-assess-a-company/overview'

    # we are logged in but can't see the Log out option without js.
    expect(page).to have_content('Opportunities Enquiries Stats')
    expect(page).to have_content('You will need to assess whether a company is both eligible and suitable')

    visit '/admin/editors/sign_in'

    expect_editor_to_be_logged_in
  end

  scenario 'Attempting to log in to an account that does not exist' do
    visit new_editor_session_path

    within '#new_editor' do
      fill_in 'Email',    with: 'nonexistent@example.com'
      fill_in 'Password', with: 'wibble-sidecar-sling'
      click_on 'Log in'
    end

    expect_editor_to_be_logged_out

    expect(page).to have_content(I18n.t('devise.failure.invalid'))
  end

  feature 'Attempting to log in with the wrong password' do
    scenario 'displays an error' do
      create(:editor, email: 'email@example.com', password: 'correct-password')

      visit new_editor_session_path

      within '#new_editor' do
        fill_in 'Email',    with: 'email@example.com'
        fill_in 'Password', with: 'wrong-password'
        click_on 'Log in'
      end

      expect_editor_to_be_logged_out

      expect(page).to have_content(I18n.t('devise.failure.invalid'))
    end

    scenario 'account is locked after a number of attempts' do
      allow(Devise).to receive(:maximum_attempts).and_return(1)

      create(:editor, email: 'email@example.com', password: 'correct-password')

      visit new_editor_session_path

      # Attempt #1
      within '#new_editor' do
        fill_in 'Email',    with: 'email@example.com'
        fill_in 'Password', with: 'wrong-password'
        click_on 'Log in'
      end

      # Attempt #2
      within '#new_editor' do
        fill_in 'Email',    with: 'email@example.com'
        fill_in 'Password', with: 'wrong-password'
        click_on 'Log in'
      end

      expect_editor_to_be_logged_out

      expect(page).to have_content(I18n.t('devise.failure.invalid'))
    end

    scenario 'shows an error when account is locked' do
      editor = create(:editor, email: 'email@example.com', password: 'correct-password')
      editor.lock_access!

      visit new_editor_session_path

      within '#new_editor' do
        fill_in 'Email',    with: 'email@example.com'
        fill_in 'Password', with: 'correct-password'
        click_on 'Log in'
      end

      expect_editor_to_be_logged_out

      expect(page).to have_content(I18n.t('devise.failure.invalid'))
    end

    scenario 'account can be unlocked by clicking link in email', sidekiq: :inline do
      skip('to test')
      editor = create(:editor, email: 'email@example.com', password: 'correct-password')
      editor.lock_access!

      visit new_editor_session_path

      within '#new_editor' do
        fill_in 'Email',    with: 'email@example.com'
        fill_in 'Password', with: 'correct-password'
        click_on 'Log in'
      end

      expect_editor_to_be_logged_out

      open_email 'email@example.com'
      current_email.click_link 'Unlock my account'

      visit new_editor_session_path

      within '#new_editor' do
        fill_in 'Email',    with: 'email@example.com'
        fill_in 'Password', with: 'correct-password'
        click_on 'Log in'
      end

      expect_editor_to_be_logged_in
    end
  end

  scenario 'account can be unlocked by manually requesting an unlock email', sidekiq: :inline do
    skip('to test')
    editor = create(:editor, email: 'email@example.com', password: 'correct-password')
    editor.lock_access!

    visit new_editor_session_path

    click_link "Didn't receive unlock instructions?"

    within '#new_editor' do
      fill_in 'Email', with: 'email@example.com'
      click_on 'Resend unlock instructions'
    end

    open_email 'email@example.com'
    current_email.click_link 'Unlock my account'

    visit new_editor_session_path

    within '#new_editor' do
      fill_in 'Email',    with: 'email@example.com'
      fill_in 'Password', with: 'correct-password'
      click_on 'Log in'
    end

    expect_editor_to_be_logged_in
  end

  scenario 'Password reset', sidekiq: :inline do
    create(:editor, email: 'email@example.com')

    visit new_editor_session_path
    click_on 'Forgot your password?'

    within '#new_editor' do
      fill_in 'Email', with: 'email@example.com'
      click_on 'Send me reset password instructions'
    end

    open_email('email@example.com')
    current_email.click_link 'Change my password'

    within '#new_editor' do
      fill_in 'New password',         with: 'my shiny new password'
      fill_in 'Confirm new password', with: 'my shiny new password'
      click_on 'Change my password'
    end

    expect(page).to have_text('Your password has been changed successfully')
  end

  scenario 'Password reset with a bad password', sidekiq: :inline do
    create(:editor, email: 'email@example.com')

    visit new_editor_session_path
    click_on 'Forgot your password?'

    within '#new_editor' do
      fill_in 'Email', with: 'email@example.com'
      click_on 'Send me reset password instructions'
    end

    open_email('email@example.com')
    current_email.click_link 'Change my password'

    within '#new_editor' do
      fill_in 'New password',         with: 'too-short'
      fill_in 'Confirm new password', with: 'too-short'
      click_on 'Change my password'
    end

    expect(page).to have_text('Password is too short')

    within '#edit_editor' do
      fill_in 'New password',         with: 'password12345'
      fill_in 'Confirm new password', with: 'password12345'
      click_on 'Change my password'
    end

    expect(page).to have_text('Password is too easy to guess')

    within '#edit_editor' do
      fill_in 'New password',         with: '1q2w3e4r5t'
      fill_in 'Confirm new password', with: '1q2w3e4r5t'
      click_on 'Change my password'
    end

    expect(page).to have_text('Password is too easy to guess')
  end

  scenario 'Remember me' do
    create(:editor, email: 'email@example.com', password: 'wibble-sidecar-sling')

    visit new_editor_session_path

    within '#new_editor' do
      fill_in 'Email',    with: 'email@example.com'
      fill_in 'Password', with: 'wibble-sidecar-sling'
      check 'Remember me'
      click_on 'Log in'
    end

    end_session

    visit admin_opportunities_path

    expect_editor_to_be_logged_in
  end

  scenario 'Logging out' do
    editor = create(:editor)
    login_as(editor)

    visit admin_opportunities_path
    click_on 'Log out'

    expect_editor_to_be_logged_out
  end

  private

  def expect_editor_to_be_logged_in
    expect(page).to have_text('Title')
  end

  def expect_editor_to_be_logged_out
    expect(page).to have_no_selector(:link_or_button, 'Log out')
  end

  def end_session
    session_cookie_name = '_ukti_opportunities_session'
    page.driver.browser.set_cookie("#{session_cookie_name}:")
  end
end
