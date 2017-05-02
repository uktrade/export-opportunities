require 'rails_helper'

feature 'Uploaders can create drafts' do
  scenario 'and view their own drafted opportunities' do
    uploader = create(:uploader)
    opportunity = create(:opportunity, :drafted, author: uploader)

    login_as(uploader)
    visit admin_opportunities_path

    click_on 'Draft'

    expect(page.status_code).to eq 200
    expect(page).to have_content(opportunity.title)
  end

  scenario 'and set it to trash' do
    uploader = create(:uploader)
    opportunity = create(:opportunity, :drafted, author: uploader)

    login_as(uploader)
    visit admin_opportunities_path

    click_on 'Draft'
    click_on opportunity.title

    expect(page.status_code).to eq 200

    click_on 'Trash'
    expect(page.status_code).to eq 200
    expect(page).to have_content('This opportunity was moved to Trash')
  end

  scenario 'and set it to pending' do
    uploader = create(:uploader)
    opportunity = create(:opportunity, :drafted, author: uploader)

    login_as(uploader)
    visit admin_opportunities_path

    click_on 'Draft'
    click_on opportunity.title

    expect(page.status_code).to eq 200

    click_on 'Pending'
    expect(page.status_code).to eq 200
    expect(page).to have_content('This opportunity has been set to pending')
  end

  scenario 'and change the opportunity status to drafted from trash and back' do
    uploader = create(:uploader)
    opportunity = create(:opportunity, author: uploader, status: :trash)

    login_as(uploader)
    visit admin_opportunities_path

    click_on opportunity.title

    expect(page.status_code).to eq 200

    click_on 'Draft'

    expect(page.status_code).to eq 200
    expect(page).to have_content('This opportunity has been set to draft')

    click_on 'Trash'

    expect(page).to have_content('This opportunity was moved to Trash')
  end

  scenario 'Other Uploaders cant view my uploaders drafted opportunities' do
    service_provider = create(:service_provider, name: 'Provider of services')

    uploader = create(:uploader, service_provider: service_provider)
    opportunity = create(:opportunity, :drafted, author: uploader)

    secret_uploader = create(:uploader, service_provider: service_provider)
    secret_opportunity = create(:opportunity, :drafted, author: secret_uploader)

    login_as(uploader)
    visit admin_opportunities_path

    expect(page).to have_content(opportunity.title)
    expect(page).to_not have_content(secret_opportunity.title)
  end

  scenario 'Admins can view uploaders draft opportunities' do
    uploader = create(:uploader)
    opportunity = create(:opportunity, :drafted, author: uploader)

    sneaky_admin = create(:admin)

    login_as(sneaky_admin)
    visit admin_opportunities_path

    expect(page).to have_content(opportunity.title)
  end
end
