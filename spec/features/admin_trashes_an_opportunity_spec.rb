require 'rails_helper'

feature 'Trashing opportunities' do
  scenario 'Admin trashing an unpublished opportunity' do
    admin = create(:admin)
    opportunity = create(:opportunity, title: 'Unpublishable Opportunity', status: :pending)
    login_as(admin)

    visit "/admin/opportunities/#{opportunity.id}"

    click_on('Trash')

    expect(page).to have_content('This opportunity was moved to Trash')

    click_link('Opportunities')
    click_link('Trash')

    expect(page).to have_content('Unpublishable Opportunity')
  end

  scenario 'non-admin trashing their own unpublished opportunity' do
    uploader = create(:uploader)
    opportunity = create(:opportunity, author: uploader, title: 'Unpublishable Opportunity', status: :pending)
    login_as(uploader)

    visit "/admin/opportunities/#{opportunity.id}"

    expect(page).to have_content('Unpublishable Opportunity')
    expect(page).to have_no_link('Trash')
    expect(page).to have_no_button('Trash')
  end

  scenario 'admin trashing a published opportunity' do
    admin = create(:admin)
    opportunity = create(:opportunity, title: 'Unpublishable Opportunity', status: :publish)
    login_as(admin)

    visit "/admin/opportunities/#{opportunity.id}"

    expect(page).to have_content('Unpublishable Opportunity')
    expect(page).to have_no_link('Trash')
    expect(page).to have_no_button('Trash')
  end

  scenario 'Admin restoring a trashed opportunity' do
    admin = create(:admin)
    opportunity = create(:opportunity, title: 'Trashed Opportunity', status: :trash)

    login_as(admin)

    visit "/admin/opportunities/#{opportunity.id}"
    click_on('Restore')
    expect(page).to have_content('This opportunity has been set to pending')

    click_link('Opportunities')
    click_link('Pending')
    expect(page).to have_content('Trashed Opportunity')
  end

  scenario 'Non-admin restoring a trashed opportunity' do
    uploader = create(:uploader)
    opportunity = create(:opportunity, title: 'Trashed Opportunity', author: uploader, status: :trash)

    login_as(uploader)

    visit "/admin/opportunities/#{opportunity.id}"
    expect(page).to have_content('Trashed Opportunity')
    expect(page).to have_no_button('Restore')
  end
end
