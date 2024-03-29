require 'rails_helper'

feature 'Uploaders are restricted' do
  scenario 'Uploaders can edit their own opportunities' do
    uploader = create(:uploader)
    opportunity = create(:opportunity, author: uploader)
    create(:type, name: 'Public Sector')
    create(:value, name: 'More than £100k')
    create(:supplier_preference)

    login_as(uploader)
    visit admin_opportunities_path

    click_on opportunity.title
    click_on 'Edit opportunity'

    expect(page.status_code).to eq 200

    fill_in 'opportunity_title', with: 'A revised opportunity'
    click_on 'Save and continue'

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

    visit '/export-opportunities/admin/opportunities'

    expect(page).not_to have_content(anothers_pending_opportunity.title)
    expect(page).to have_content(anothers_published_opportunity.title)
  end

  scenario 'Uploaders can see other editors’ opportunities from the same service provider' do
    shared_service_provider = create(:service_provider)
    opportunity_from_same_provider = create(:opportunity, author: create(:uploader), service_provider: shared_service_provider)
    uploader = create(:uploader, service_provider: shared_service_provider)
    login_as(uploader)

    visit '/export-opportunities/admin/opportunities'

    expect(page).to have_content(opportunity_from_same_provider.title)
  end

  scenario 'Uploaders cannot see enquiries for others opportunities' do
    service_provider_id = 100.freeze
    shared_service_provider = create(:service_provider, id: service_provider_id)
    irrelevant_service_provider = create(:service_provider)

    uploader = create(:uploader, service_provider: shared_service_provider)
    opportunity = create(:opportunity, service_provider_id: service_provider_id, author: uploader)
    create(:enquiry, company_name: 'British Sponges', opportunity: opportunity)

    another_uploader = create(:uploader, service_provider: shared_service_provider)
    another_opportunity = create(:opportunity, service_provider_id: service_provider_id, author: another_uploader)
    create(:enquiry, company_name: 'Shepherd Pie Inc', opportunity: another_opportunity)

    third_uploader = create(:uploader, service_provider: irrelevant_service_provider)
    third_opportunity = create(:opportunity, author: third_uploader)
    create(:enquiry, company_name: 'Universal Exports', opportunity: third_opportunity)

    login_as(uploader)
    visit '/export-opportunities/admin/enquiries'

    # an enquiry not matching an opportunity the uploader created is not visible
    expect(page).not_to have_content('Universal Exports')
    # an enquiry for an opportunity that the uploader created should be visible
    expect(page).to have_content('British Sponges')
    # and enquiry for an opportunity created by another uploader in the same service provider should be visible
    expect(page).to have_content('Shepherd Pie Inc')
  end

  scenario 'Uploaders can not see list of enquiries in opportunity show page for opportunities not created within the same service provider' do
    one_service_provider = create(:service_provider)
    another_service_provider = create(:service_provider)

    uploader = create(:uploader, service_provider: one_service_provider)
    opportunity = create(:opportunity, :published, author: uploader)

    create(:enquiry, company_name: 'Universal Exports', opportunity: opportunity)
    create(:enquiry, company_name: 'British Sponges', opportunity: opportunity)
    create(:enquiry, company_name: 'Shepherd Pie Inc', opportunity: opportunity)

    another_uploader = create(:uploader, service_provider: another_service_provider)

    login_as(another_uploader)
    visit '/export-opportunities/admin/opportunities'

    click_on opportunity.title

    # an enquiry not matching an opportunity the uploader created is not visible
    expect(page).not_to have_content('Universal Exports')
    # an enquiry for an opportunity that the uploader created should be visible
    expect(page).not_to have_content('British Sponges')
    # and enquiry for an opportunity created by another uploader in the same service provider should be visible
    expect(page).not_to have_content('Shepherd Pie Inc')
  end

  scenario 'Uploaders CAN see list of enquiries in opportunity show page for opportunities created within the same service provider' do
    shared_service_provider = create(:service_provider)

    uploader = create(:uploader, service_provider: shared_service_provider)
    opportunity = create(:opportunity, :published, author: uploader, service_provider: shared_service_provider)

    create(:enquiry, company_name: 'Universal Exports', opportunity: opportunity)
    create(:enquiry, company_name: 'British Sponges', opportunity: opportunity)
    create(:enquiry, company_name: 'Shepherd Pie Inc', opportunity: opportunity)

    another_uploader = create(:uploader, service_provider: shared_service_provider)

    login_as(another_uploader)
    visit '/export-opportunities/admin/opportunities'

    click_on opportunity.title

    # an enquiry not matching an opportunity the uploader created is not visible
    expect(page).to have_content('Universal Exports')
    # an enquiry for an opportunity that the uploader created should be visible
    expect(page).to have_content('British Sponges')
    # and enquiry for an opportunity created by another uploader in the same service provider should be visible
    expect(page).to have_content('Shepherd Pie Inc')
  end

  scenario 'Uploaders do not see others’ enquiries in CSV' do
    uploader = create(:uploader)
    create(:enquiry, company_name: 'Universal Exports')

    login_as(uploader)
    visit '/export-opportunities/admin/enquiries'

    click_on 'Enquiries'
    click_on 'Generate report'

    expect(page).not_to have_content('Universal Exports')
  end

  scenario 'Uploaders do not see others’ unpublished opportunities in CSV' do
    skip('works IRL, need to update test')
    uploader = create(:uploader)
    create(:opportunity, created_at: 1.day.ago, title: 'Opportunity in Progress')
    create(:opportunity, :published, created_at: 1.day.ago, title: 'Ready opportunity')

    login_as(uploader)
    visit '/export-opportunities/admin/opportunities'

    click_on 'Download'
    click_on 'Download as CSV'

    expect(page).not_to have_content('Opportunity in Progress')
    expect(page).to have_content('Ready opportunity')
  end

  scenario 'Cannot see other editors' do
    uploader = create(:uploader)

    login_as(uploader)
    visit '/export-opportunities/admin/editors'

    expect(page.status_code).to eq(404)
    expect(page).to have_text('This page cannot be found')
    expect(page).to_not have_selector(:link_or_button, 'Editors')
  end

  scenario 'Cannot create a new editor' do
    uploader = create(:uploader)

    login_as(uploader)
    visit '/export-opportunities/admin/editors/new'

    expect(page.status_code).to eq(404)
    expect(page).to have_text('This page cannot be found')
    expect(page).to_not have_selector(:link_or_button, 'Editors')
  end

  scenario 'Uploaders can not view volume_opps opportunities' do
    dit_hq_service_provider = create(:service_provider, name: 'DIT HQ')
    another_service_provider = create(:service_provider, name: 'Italy')

    uploader_volume_opps = create(:uploader, service_provider: dit_hq_service_provider)
    uploader_post = create(:uploader, service_provider: another_service_provider)

    anothers_pending_opportunity = create(:opportunity, source: :volume_opps, author: uploader_volume_opps)
    anothers_published_opportunity = create(:opportunity, :published, source: :volume_opps, author: uploader_volume_opps)
    login_as(uploader_post)

    visit '/export-opportunities/admin/opportunities'

    expect(page).not_to have_content(anothers_pending_opportunity.title)
    expect(page).not_to have_content(anothers_published_opportunity.title)
  end
end
