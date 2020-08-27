# coding: utf-8
require 'rails_helper'
require 'capybara/email/rspec'

feature 'Admins manage editors' do
  let(:content) { get_content('admin/editors') }

  before(:each) do
    clear_emails
  end

  scenario 'Can view all of the editors' do
    admin = create(:admin)
    provider = create(:service_provider)
    existing_editor = create(:editor, last_sign_in_at: Time.zone.parse('Thu, 09 Mar 2017 14:11'), service_provider: provider)

    login_as(admin)
    visit admin_editors_path

    expect(page).to have_text(existing_editor.name)
    expect(page).to have_text(existing_editor.email)
    expect(page).to have_text(existing_editor.role.capitalize)
    expect(page).to have_text(existing_editor.last_sign_in_at.strftime("%d %h %Y%l:%M %p"))
    expect(page).to have_text(existing_editor.service_provider.name)
  end

  scenario 'Can view a single editor' do
    editor = create(:editor)
    admin = create(:admin)

    login_as(admin)

    visit admin_editors_path
    click_on(editor.name)

    expect(page).to have_text(editor.name)
  end

  scenario 'Can delete an editor' do
    editor = create(:editor)
    admin = create(:admin)

    login_as(admin)

    visit admin_editor_path(editor.id)
    click_button(content['button_deactivate'])
    expect(page).to have_text(I18n.t('devise.registrations.destroyed'))
  end

  scenario 'Can reactivate a deleted editor' do
    editor = create(:editor)
    admin = create(:admin)

    login_as(admin)

    visit admin_editor_path(editor.id)
    click_button(content['button_deactivate'])
    expect(page).to have_text(I18n.t('devise.registrations.destroyed'))

    visit admin_editor_path(editor.id)
    click_button(content['button_reactivate'])
    expect(page).to have_text(I18n.t('devise.registrations.reactivated'))
  end

  scenario 'An editor who has been deactivated is signed out' do
    editor = create(:editor)
    admin = create(:admin)

    Capybara.using_session(:editor) do
      login_as(editor)
      visit '/export-opportunities/admin/opportunities'
      expect(page).to have_link 'New opportunity'
    end

    Capybara.using_session(:admin) do
      login_as(admin)
      visit "/export-opportunities/admin/editors/#{editor.id}"
      click_button content['button_deactivate']
    end

    Capybara.using_session(:editor) do
      visit '/export-opportunities/admin/opportunities'
      expect(page).to have_content 'Log in'
    end
  end

  scenario 'Can change a editors’s service provider' do
    create(:service_provider, name: 'France Paris')
    existing_editor = create(:uploader)
    admin = create(:admin)

    login_as(admin)

    visit admin_editor_path(existing_editor.id)
    click_on(content['button_edit'])

    select('France Paris', from: 'Service provider')
    click_button(content['button_update'])

    expect(page).to have_text('Editor updated')
    expect(page).to have_text('Service provider')
    expect(page).to have_text('France Paris')
  end

  scenario 'Can change a editors’s role' do
    existing_editor = create(:uploader)
    admin = create(:admin)

    login_as(admin)

    visit admin_editor_path(existing_editor.id)
    expect(page).to have_text('Uploader')
    click_on content['button_edit']
    select('Publisher', from: 'Role')
    click_button(content['button_update'])

    expect(page).to have_text('Editor updated')
    expect(page).to have_text('Publisher')
  end

  scenario 'When editors are deactivated' do
    deactivated_editor = create(:uploader, deactivated_at: Time.zone.yesterday)
    admin = create(:admin)

    login_as(admin)

    visit admin_editors_path

    expect(page).not_to have_text(deactivated_editor.name)

    check 'Show deactivated'
    click_on 'Filter'

    expect(page).to have_text(deactivated_editor.name)
    expect(page).to have_text('Deactivated')

    visit admin_editor_path(deactivated_editor.id)
    expect(page).to have_text('This user has been deactivated')
    expect(page).to have_no_button('Deactivate Editor')
  end

  context 'with and without service provider fields' do
    it 'hides the service provider dropdown when editing an editor who is not an uploader' do
      uploader = create(:uploader)
      publisher = create(:publisher)
      admin = create(:admin)

      login_as(admin)

      visit "/export-opportunities/admin/editors/#{uploader.id}/edit"
      expect(page).to have_select 'editor[service_provider_id]'

      visit "/export-opportunities/admin/editors/#{publisher.id}/edit"
      expect(page).not_to have_select 'editor[service_provider_id]'
    end

    it 'hides the service provider field on the show page for an editor who is not an uploader' do
      uploader = create(:uploader)
      publisher = create(:publisher)
      admin = create(:admin)
      service_provider = 'editor[service_provider_id]'

      login_as(admin)

      visit "/export-opportunities/admin/editors/#{uploader.id}"
      expect(page.has_select?(service_provider))

      visit "/export-opportunities/admin/editors/#{publisher.id}"
      expect(page.has_no_select?(service_provider))
    end
  end
end
