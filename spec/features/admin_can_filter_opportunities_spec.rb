# coding: utf-8
require 'rails_helper'

RSpec.feature 'Admin can filter opportunities' do
  scenario 'an uploader can see all filtering links' do
    uploader = create(:uploader)
    login_as(uploader)
    visit admin_opportunities_path

    expect(page).to have_link('Published')
    expect(page).to have_link('Pending')
    expect(page).to have_link('Trashed')
    expect(page).to have_link('Draft')
  end

  scenario 'a previewer can see all filtering links' do
    uploader = create(:previewer)
    login_as(uploader)
    visit admin_opportunities_path

    expect(page).to have_link('Published')
    expect(page).to have_link('Pending')
    expect(page).to have_link('Trashed')
    expect(page).to have_link('Draft')
  end

  scenario 'a publisher can see all filtering links' do
    uploader = create(:publisher)
    login_as(uploader)
    visit admin_opportunities_path

    expect(page).to have_link('Published')
    expect(page).to have_link('Pending')
    expect(page).to have_link('Trashed')
    expect(page).to have_link('Draft')
  end

  scenario 'an admin can see all filtering links' do
    uploader = create(:admin)
    login_as(uploader)
    visit admin_opportunities_path

    expect(page).to have_link('Published')
    expect(page).to have_link('Pending')
    expect(page).to have_link('Trashed')
    expect(page).to have_link('Draft')
  end

  scenario 'Editor preference for showing and hiding expired opportunities persists when changing filters (All,Pending,Published,Trashed)' do
    login_as(create(:publisher))
    result_item_selector = '.results tbody tr'
    visit admin_opportunities_path

    non_expired_published_opportunity = create(:opportunity, status: :publish)
    expired_published_opportunity = create(:opportunity, :expired, status: :publish)
    expired_pending_opportunity = create(:opportunity, :expired, status: :pending)

    expect(page).to have_content('Expired opportunities are hidden')
    expect(page).to have_content('Show expired opportunities')

    within('.filters') { click_link('Pending') }
    expect(page).to have_no_selector(result_item_selector)
    expect(page).to have_no_text expired_pending_opportunity.title

    within('.filters') { click_link('Published') }
    expect(page).to have_selector(result_item_selector, count: 1)
    expect(page).to have_no_text expired_published_opportunity.title
    expect(page).to have_no_text expired_pending_opportunity.title
    expect(page).to have_text non_expired_published_opportunity.title

    click_on('Show expired')
    expect(page).to have_selector(result_item_selector, count: 2)
    expect(page).to have_text non_expired_published_opportunity.title
    expect(page).to have_text expired_published_opportunity.title

    within('.filters') { click_link('Pending') }
    expect(page).to have_selector(result_item_selector, count: 1)
    expect(page).to have_no_text non_expired_published_opportunity.title
    expect(page).to have_no_text expired_published_opportunity.title
    expect(page).to have_text expired_pending_opportunity.title
  end

  scenario 'filters opportunities' do
    login_as(create(:publisher))
    published_opportunity = create(:opportunity, status: :publish)
    pending_opportunity = create(:opportunity, status: :pending)
    trashed_opportunity = create(:opportunity, status: :trash)
    result_item_selector = '.results tbody tr'

    expired_published_opportunity = create(:opportunity, :expired, status: :publish)
    expired_pending_opportunity = create(:opportunity, :expired, status: :pending)
    expired_trashed_opportunity = create(:opportunity, :expired, status: :trash)

    # All opportunities showing is default
    visit admin_opportunities_path

    expect(page).to have_selector(result_item_selector, count: 3)
    expect(page).to have_text published_opportunity.title
    expect(page).to have_text pending_opportunity.title
    expect(page).to have_text trashed_opportunity.title

    expect(page).to have_no_text expired_published_opportunity.title
    expect(page).to have_no_text expired_pending_opportunity.title
    expect(page).to have_no_text expired_trashed_opportunity.title

    click_on('Show expired')

    expect(page).to have_selector(result_item_selector, count: 6)
    expect(page).to have_text expired_published_opportunity.title
    expect(page).to have_text expired_pending_opportunity.title
    expect(page).to have_text expired_trashed_opportunity.title

    click_on('Hide expired')

    expect(page).to have_selector(result_item_selector, count: 3)
    expect(page).to have_no_text expired_published_opportunity.title
    expect(page).to have_no_text expired_pending_opportunity.title
    expect(page).to have_no_text expired_trashed_opportunity.title

    within('.filters') { click_link('Published') }
    expect(page).to have_selector(result_item_selector, count: 1)
    expect(page).to have_text published_opportunity.title
    expect(page).to have_no_text expired_published_opportunity.title

    click_on('Show expired')

    expect(page).to have_selector(result_item_selector, count: 2)
    expect(page).to have_text expired_published_opportunity.title

    click_on('Hide expired')

    expect(page).to have_selector(result_item_selector, count: 1)
    expect(page).to have_no_text expired_published_opportunity.title

    within('.filters') { click_link('Pending') }
    expect(page).to have_selector(result_item_selector, count: 1)
    expect(page).to have_text pending_opportunity.title
    expect(page).to have_no_text expired_pending_opportunity.title

    click_on('Show expired')

    expect(page).to have_selector(result_item_selector, count: 2)
    expect(page).to have_text expired_pending_opportunity.title

    click_on('Hide expired')

    expect(page).to have_selector(result_item_selector, count: 1)
    expect(page).to have_no_text expired_pending_opportunity.title

    within('.filters') { click_link('Trashed') }
    expect(page).to have_selector(result_item_selector, count: 1)
    expect(page).to have_text trashed_opportunity.title
    expect(page).to have_no_text expired_trashed_opportunity.title

    click_on('Show expired')

    expect(page).to have_selector(result_item_selector, count: 2)
    expect(page).to have_text expired_trashed_opportunity.title

    click_on('Hide expired')

    expect(page).to have_selector(result_item_selector, count: 1)
    expect(page).to have_no_text expired_trashed_opportunity.title
  end

  scenario 'changing between filters maintains search criteria' do
    login_as(create(:publisher))

    visit admin_opportunities_path

    matching_published_opportunity = create(:opportunity, :published, title: 'matching')
    matching_unpublished_opportunity = create(:opportunity, title: 'matching but pending')
    non_matching_published_opportunity = create(:opportunity, :published, title: 'wrong')

    fill_in :s, with: 'matching'
    click_on 'Search'

    expect(page).to have_content(matching_published_opportunity.title)
    expect(page).to have_content(matching_unpublished_opportunity.title)
    expect(page).to have_no_content(non_matching_published_opportunity.title)

    click_on 'Published'

    expect(page).to have_content(matching_published_opportunity.title)
    expect(page).to have_no_content(matching_unpublished_opportunity.title)
    expect(page).to have_no_content(non_matching_published_opportunity.title)
  end

  scenario 'sorting opportunities does not affect filtering' do
    login_as(create(:uploader))

    published_opportunity = create(:opportunity, :published, title: 'published opportunity')
    pending_opportunity = create(:opportunity, status: :pending, title: 'pending opportunity')

    visit admin_opportunities_path

    within('.filters') { click_link('Published') }

    expect(page).to have_content(published_opportunity.title)
    expect(page).to have_no_content(pending_opportunity.title)

    # Sort by title
    click_on 'Title'

    expect(page).to have_content(published_opportunity.title)
    expect(page).to have_no_content(pending_opportunity.title)
  end

  scenario 'filters persist after viewing an opportunity' do
    login_as(create(:uploader))

    create(:opportunity, :published, title: 'published opportunity')
    create(:opportunity, :unpublished, title: 'pending opportunity')
    create(:opportunity, :published, :expired, title: 'expired opportunity')

    visit '/export-opportunities/admin/opportunities'

    within('.filters') { click_link('Published') }
    click_on 'Title'
    click_on 'Show expired'

    expect(page).to have_no_content('pending opportunity')
    expect('expired opportunity').to appear_before('published opportunity')

    click_on 'published opportunity'
    page.first(:link, 'Back').click

    expect(page).to have_no_content('pending opportunity')
    expect('expired opportunity').to appear_before('published opportunity')
  end

  scenario 'filters persist after editing an opportunity' do
    login_as(create(:admin))

    create(:opportunity, :published, title: 'published opportunity')
    create(:opportunity, :unpublished, title: 'pending opportunity')
    create(:opportunity, :published, :expired, title: 'expired opportunity')
    create(:type, name: 'Public Sector')
    create(:value, name: 'More than £100k')
    create(:supplier_preference)

    visit '/export-opportunities/admin/opportunities'

    # Default state:
    expect('pending opportunity').to appear_before('published opportunity')
    expect(page).to have_no_content('expired opportunity')

    within('.filters') { click_link('Published') }
    click_on 'Title'
    click_on 'Show expired'

    expect(page).to have_no_content('pending opportunity')
    expect('expired opportunity').to appear_before('published opportunity')

    click_on 'published opportunity'
    click_on 'Edit opportunity'
    click_on 'Save and continue'
    page.first(:link, 'Back').click

    expect(page).to have_no_content('pending opportunity')
    expect('expired opportunity').to appear_before('published opportunity')
  end

  scenario 'pagination persists after viewing an opportunity' do
    publisher = create(:publisher)
    login_as(publisher)
    result_item_selector = '.results tbody tr'
    create(:opportunity, title: 'last opp')
    create_list(:opportunity, Admin::OpportunitiesController::OPPORTUNITIES_PER_PAGE)

    visit '/export-opportunities/admin/opportunities'
    within('.pagination') { click_link '2' }

    expect(page).to have_selector(result_item_selector, count: 1)
    expect(page).to have_text 'last opp'

    click_on 'last opp'
    page.first(:link, 'Back').click

    expect(page).to have_selector(result_item_selector, count: 1)
    expect(page).to have_text 'last opp'
  end
end
