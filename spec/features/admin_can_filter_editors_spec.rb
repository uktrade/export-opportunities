require 'rails_helper'

RSpec.feature 'Admin can filter editors' do
  scenario 'sees filtering links' do
    admin = create(:admin)
    login_as(admin)
    visit admin_editors_path

    expect(page).to have_button('Filter')
    expect(page).to have_link('Reset')
  end

  scenario 'filters persists when changing filters' do
    admin = create(:admin)
    service_provider = create(:service_provider)

    login_as(admin)
    visit admin_editors_path

    check 'Show deactivated'
    select service_provider.name, from: 'Service provider:'
    click_on 'Filter'

    expect(page).to have_current_path(/show_deactivated=1/)
    expect(page).to have_checked_field('Show deactivated')
    expect(page).to have_select('Service provider:', selected: service_provider.name)
  end

  scenario 'sort order persists when changing filters' do
    admin = create(:admin)

    login_as(admin)
    visit admin_editors_path

    click_on 'Role'

    check 'Show deactivated'
    click_on 'Filter'

    expect(page).to have_current_path(/sort\[column\]=role&sort\[order\]=asc/)
  end

  scenario 'shows deactivated editors' do
    admin = create(:admin)
    deactivated_editor = create(:deactivated)
    active_editor = create(:editor)

    login_as(admin)
    visit admin_editors_path

    expect(page).to have_no_content(deactivated_editor.name)
    expect(page).to have_content(active_editor.name)

    check 'Show deactivated'
    click_on 'Filter'

    expect(page).to have_content(deactivated_editor.name)
    expect(page).to have_content(active_editor.name)
  end

  scenario 'filters by Service provider' do
    first_service_provider = create(:service_provider)
    second_service_provider = create(:service_provider)

    admin = create(:admin)
    first_editor = create(:editor, service_provider: first_service_provider)
    second_editor = create(:editor, service_provider: second_service_provider)

    login_as(admin)
    visit admin_editors_path

    expect(page).to have_content(first_editor.name)
    expect(page).to have_content(second_editor.name)

    select first_service_provider.name, from: 'Service provider:'
    click_on 'Filter'

    expect(page).to have_content(first_editor.name)
    expect(page).to have_no_content(second_editor.name)
  end

  scenario 'admins can reset the filters' do
    admin = create(:admin)
    login_as(admin)
    visit admin_editors_path

    check 'Show deactivated'
    click_on 'Filter'

    expect(page).to have_current_path(/show_deactivated=1/)

    click_on 'Reset'
    expect(page).to_not have_current_path(/show_deactivated=1/)
  end
end
