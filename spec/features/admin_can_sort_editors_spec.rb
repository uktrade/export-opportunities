require 'rails_helper'

feature 'Admin can sort the list of editors' do
  before(:each) do
    create(:service_provider, name: 'London UK', id: 1)
    create(:service_provider, name: 'Paris France', id: 2)
    create(:service_provider, name: 'Berlin Germany', id: 3)
  end

  scenario 'by name' do
    first_editor = create(:editor, service_provider_id: 1, name: 'alex')
    second_editor = create(:editor, service_provider_id: 1, name: 'bobby')
    third_admin = create(:admin, service_provider_id: 1, name: 'catherine')

    login_as(third_admin)
    visit '/export-opportunities/admin/editors'

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
    first_editor = create(:editor, service_provider_id: 1, email: 'alex@al.com')
    second_editor = create(:editor, service_provider_id: 1, email: 'bobby@bo.com')
    third_admin = create(:admin, service_provider_id: 1, email: 'cathy@cee.com')
    login_as(third_admin)
    visit '/export-opportunities/admin/editors'

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
    first_editor = create(:editor, service_provider_id: 1, confirmed_at: 2.days.ago)
    second_editor = create(:editor, service_provider_id: 1, confirmed_at: 3.days.ago)
    third_admin = create(:admin, service_provider_id: 1, confirmed_at: 1.day.ago)
    login_as(third_admin)
    visit '/export-opportunities/admin/editors'

    click_on 'Confirmed'

    # On some developers machines, the %l in "to_s(:admin_datetime)" will have an extra whitespace in the tests
    # code but not in the view code run by the tests, causing the tests to fail. Therefore substitute for
    # strftime("%d %h %Y")
    expect(page.find('tbody tr:nth-child(1)')).to have_content(second_editor.confirmed_at.strftime("%d %h %Y"))
    expect(page.find('tbody tr:nth-child(2)')).to have_content(first_editor.confirmed_at.strftime("%d %h %Y"))
    expect(page.find('tbody tr:nth-child(3)')).to have_content(third_admin.confirmed_at.strftime("%d %h %Y"))

    click_on 'Confirmed'

    expect(page.find('tbody tr:nth-child(1)')).to have_content(third_admin.confirmed_at.strftime("%d %h %Y"))
    expect(page.find('tbody tr:nth-child(2)')).to have_content(first_editor.confirmed_at.strftime("%d %h %Y"))
    expect(page.find('tbody tr:nth-child(3)')).to have_content(second_editor.confirmed_at.strftime("%d %h %Y"))
  end

  scenario 'by service provider' do
    create(:editor, name: 'alex', service_provider_id: 1)
    create(:editor, name: 'bobby', service_provider_id: 2)
    admin = create(:admin, name: 'catherine', service_provider_id: 3)
    login_as(admin)
    visit '/export-opportunities/admin/editors'

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
    Admin::EditorsController::EDITORS_PER_PAGE.times do |loop|
      create(:editor, service_provider_id: 1)
    end
    admin = create(:admin, service_provider_id: 1, name: 'catherine')
    login_as(admin)
    visit '/export-opportunities/admin/editors'
    within('.pagination') { click_link '2' }

    expect(page).to have_selector('tr.editor', count: 1)
  end
end
