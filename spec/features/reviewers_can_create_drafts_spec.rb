require 'rails_helper'

feature 'Previewers can create drafts' do
  scenario 'and view their own drafted opportunities' do
    previewer = create(:previewer)
    opportunity = create(:opportunity, :drafted, author: previewer)

    login_as(previewer)
    visit admin_opportunities_path

    click_on 'Draft'

    expect(page.status_code).to eq 200
    expect(page).to have_content(opportunity.title)
  end

  scenario 'and set it to trash' do
    previewer = create(:previewer)
    opportunity = create(:opportunity, :drafted, author: previewer)

    login_as(previewer)
    visit admin_opportunities_path

    click_on 'Draft'
    click_on opportunity.title

    expect(page.status_code).to eq 200

    click_on 'Trash'
    expect(page.status_code).to eq 200
    expect(page).to have_content('This opportunity was moved to Trash')
  end

  scenario 'and set it to pending' do
    previewer = create(:previewer)
    opportunity = create(:opportunity, :drafted, author: previewer)

    login_as(previewer)
    visit admin_opportunities_path

    click_on 'Draft'
    click_on opportunity.title

    expect(page.status_code).to eq 200

    click_on 'Pending'
    expect(page.status_code).to eq 200
    expect(page).to have_content('This opportunity has been set to pending')
  end

  scenario 'and change the opportunity status to drafted from trash and back' do
    previewer = create(:previewer)
    opportunity = create(:opportunity, author: previewer, status: :trash)

    login_as(previewer)
    visit admin_opportunities_path

    click_on opportunity.title

    expect(page.status_code).to eq 200

    click_on 'Draft'

    expect(page.status_code).to eq 200
    expect(page).to have_content('This opportunity has been set to draft')

    click_on 'Trash'

    expect(page).to have_content('This opportunity was moved to Trash')
  end

  scenario 'previewers can view anything - including other previewers drafted opportunities' do
    service_provider = create(:service_provider, name: 'Provider of services')

    previewer = create(:previewer, service_provider: service_provider)
    opportunity = create(:opportunity, :drafted, author: previewer)

    secret_previewer = create(:previewer, service_provider: service_provider)
    secret_opportunity = create(:opportunity, :drafted, author: secret_previewer)

    login_as(previewer)
    visit admin_opportunities_path

    expect(page).to have_content(opportunity.title)
    expect(page).to have_content(secret_opportunity.title)
  end

  scenario 'Admins can view previewers draft opportunities' do
    previewer = create(:previewer)
    opportunity = create(:opportunity, :drafted, author: previewer)

    sneaky_admin = create(:admin)

    login_as(sneaky_admin)
    visit admin_opportunities_path

    expect(page).to have_content(opportunity.title)
  end
end
