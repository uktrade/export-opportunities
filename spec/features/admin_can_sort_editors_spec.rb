require 'rails_helper'

feature 'Admin can sort the list of editors' do
  before(:each) do
    create(:service_provider, name: 'London UK', id: 1)
    create(:service_provider, name: 'Paris France', id: 2)
    create(:service_provider, name: 'Berlin Germany', id: 3)
  end

  scenario 'by name' do
    first_editor = create(:editor, name: 'alex')
    second_editor = create(:editor, name: 'bobby')
    third_admin = create(:admin, name: 'catherine')

    login_as(third_admin)
    visit '/admin/editors'

    expect(page.find('tbody tr:nth-child(1)')).to have_content(first_editor.name)
    expect(page.find('tbody tr:nth-child(2)')).to have_content(second_editor.name)
    expect(page.find('tbody tr:nth-child(3)')).to have_content(third_admin.name)

    click_on 'Name'

    expect(page.find('tbody tr:nth-child(1)')).to have_content(third_admin.name)
    expect(page.find('tbody tr:nth-child(2)')).to have_content(second_editor.name)
    expect(page.find('tbody tr:nth-child(3)')).to have_content(first_editor.name)

    click_on 'Name'

    expect(page.find('tbody tr:nth-child(1)')).to have_content(first_editor.name)
    expect(page.find('tbody tr:nth-child(2)')).to have_content(second_editor.name)
    expect(page.find('tbody tr:nth-child(3)')).to have_content(third_admin.name)
  end

  scenario 'by email' do
    first_editor = create(:editor, email: 'alex@al.com')
    second_editor = create(:editor, email: 'bobby@bo.com')
    third_admin = create(:admin, email: 'cathy@cee.com')
    login_as(third_admin)
    visit '/admin/editors'

    click_on 'Email'

    expect(page.find('tbody tr:nth-child(1)')).to have_content(first_editor.email)
    expect(page.find('tbody tr:nth-child(2)')).to have_content(second_editor.email)
    expect(page.find('tbody tr:nth-child(3)')).to have_content(third_admin.email)

    click_on 'Email'

    expect(page.find('tbody tr:nth-child(1)')).to have_content(third_admin.email)
    expect(page.find('tbody tr:nth-child(2)')).to have_content(second_editor.email)
    expect(page.find('tbody tr:nth-child(3)')).to have_content(first_editor.email)
  end

  scenario 'by confirmed at' do
    first_editor = create(:editor, confirmed_at: 2.days.ago)
    second_editor = create(:editor, confirmed_at: 3.days.ago)
    third_admin = create(:admin, confirmed_at: 1.day.ago)
    login_as(third_admin)
    visit '/admin/editors'

    click_on 'Confirmed'

    expect(page.find('tbody tr:nth-child(1)')).to have_content(second_editor.confirmed_at.to_s(:admin_datetime))
    expect(page.find('tbody tr:nth-child(2)')).to have_content(first_editor.confirmed_at.to_s(:admin_datetime))
    expect(page.find('tbody tr:nth-child(3)')).to have_content(third_admin.confirmed_at.to_s(:admin_datetime))

    click_on 'Confirmed'

    expect(page.find('tbody tr:nth-child(1)')).to have_content(third_admin.confirmed_at.to_s(:admin_datetime))
    expect(page.find('tbody tr:nth-child(2)')).to have_content(first_editor.confirmed_at.to_s(:admin_datetime))
    expect(page.find('tbody tr:nth-child(3)')).to have_content(second_editor.confirmed_at.to_s(:admin_datetime))
  end

  scenario 'by service provider' do
    create(:editor, name: 'alex', service_provider_id: 1)
    create(:editor, name: 'bobby', service_provider_id: 2)
    admin = create(:admin, name: 'catherine', service_provider_id: 3)
    login_as(admin)
    visit '/admin/editors'

    click_on 'Service Provider'

    expect(page.find('tbody tr:nth-child(1)')).to have_content('Berlin')
    expect(page.find('tbody tr:nth-child(2)')).to have_content('London')
    expect(page.find('tbody tr:nth-child(3)')).to have_content('Paris')

    click_on 'Service Provider'

    expect(page.find('tbody tr:nth-child(1)')).to have_content('Paris')
    expect(page.find('tbody tr:nth-child(2)')).to have_content('London')
    expect(page.find('tbody tr:nth-child(3)')).to have_content('Berlin')
  end

  scenario 'pagination shows correct results' do
    create_list(:editor, Admin::EditorsController::EDITORS_PER_PAGE)
    admin = create(:admin, name: 'catherine')
    login_as(admin)
    visit '/admin/editors'
    within('.pagination') { click_link '2' }

    expect(page).to have_selector('tr.editor', count: 1)
  end
end
