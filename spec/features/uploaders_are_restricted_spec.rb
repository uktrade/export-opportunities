require 'rails_helper'

feature 'Uploaders are restricted' do
  scenario 'Uploaders can edit their own opportunities' do
    uploader = create(:uploader)
    opportunity = create(:opportunity, author: uploader)

    login_as(uploader)
    visit admin_opportunities_path

    click_on opportunity.title
    click_on 'Edit opportunity'

    expect(page.status_code).to eq 200

    fill_in 'Title', with: 'A revised opportunity'
    click_on 'Update Opportunity'

    expect(page.status_code).to eq 200
    expect(page).to have_text('Updated opportunity "A revised opportunity"')
  end

  scenario 'Uploaders cannot edit their own published opportunities' do
    uploader = create(:uploader)
    opportunity = create(:opportunity, :published, author: uploader)

    login_as(uploader)
    visit admin_opportunities_path

    click_on opportunity.title

    expect(page).to have_no_link('Edit opportunity')
  end

  scenario 'Uploaders cannot see other editors’ opportunities unless they are published' do
    anothers_pending_opportunity = create(:opportunity, author: create(:uploader))
    anothers_published_opportunity = create(:opportunity, :published, author: create(:uploader))
    login_as(create(:uploader))

    visit '/admin/opportunities'

    expect(page).not_to have_content(anothers_pending_opportunity.title)
    expect(page).to have_content(anothers_published_opportunity.title)
  end

  scenario 'Uploaders can see other editors’ opportunities from the same service provider' do
    shared_service_provider = create(:service_provider)
    opportunity_from_same_provider = create(:opportunity, author: create(:uploader), service_provider: shared_service_provider)
    uploader = create(:uploader, service_provider: shared_service_provider)
    login_as(uploader)

    visit '/admin/opportunities'

    expect(page).to have_content(opportunity_from_same_provider.title)
  end

  scenario 'Uploaders cannot see enquiries for others’ opportunities' do
    uploader = create(:uploader)
    create(:enquiry, company_name: 'Universal Exports')

    login_as(uploader)
    visit '/admin/enquiries'

    expect(page).not_to have_content('Universal Exports')
  end

  scenario 'Uploaders do not see others’ enquiries in CSV' do
    uploader = create(:uploader)
    create(:enquiry, company_name: 'Universal Exports')

    login_as(uploader)
    visit '/admin/enquiries'

    click_on 'Enquiries'
    click_on 'Download as CSV'

    expect(page).not_to have_content('Universal Exports')
  end

  scenario 'Uploaders do not see others’ unpublished opportunities in CSV' do
    uploader = create(:uploader)
    create(:opportunity, created_at: 1.day.ago, title: 'Opportunity in Progress')
    create(:opportunity, :published, created_at: 1.day.ago, title: 'Ready opportunity')

    login_as(uploader)
    visit '/admin/opportunities'

    click_on 'Download'
    click_on 'Download as CSV'

    expect(page).not_to have_content('Opportunity in Progress')
    expect(page).to have_content('Ready opportunity')
  end

  scenario 'Cannot see other editors' do
    uploader = create(:uploader)

    login_as(uploader)
    visit '/admin/editors'

    expect(page.status_code).to eq(404)
    expect(page).to have_text('Sorry, page not found')
    expect(page).to_not have_selector(:link_or_button, 'Editors')
  end

  scenario 'Cannot create a new editor' do
    uploader = create(:uploader)

    login_as(uploader)
    visit 'admin/editors/new'

    expect(page.status_code).to eq(404)
    expect(page).to have_text('Sorry, page not found')
    expect(page).to_not have_selector(:link_or_button, 'Editors')
  end
end
