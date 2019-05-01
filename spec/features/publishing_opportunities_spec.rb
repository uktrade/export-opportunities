# coding: utf-8
require 'rails_helper'

RSpec.feature 'Publishing opportunities:' do
  scenario 'uploaders cannot publish content' do
    uploader = create(:uploader)
    opportunity = create(:opportunity, status: :pending, author: uploader)

    login_as(uploader)
    visit '/export-opportunities/admin/opportunities'
    click_on opportunity.title
    expect(page).to have_no_button('Publish')
  end

  scenario 'publishers can publish content' do
    publisher = create(:publisher)
    opportunity = create(:opportunity, status: :pending)

    login_as(publisher)
    visit '/export-opportunities/admin/opportunities'
    click_on opportunity.title
    expect(page).to have_button('Publish')
  end

  scenario 'admins can publish content' do
    admin = create(:admin)
    opportunity = create_opportunity(status: 'pending')

    login_as(admin)
    visit '/export-opportunities/admin/opportunities'
    click_on opportunity.title
    expect(page).to have_button('Publish')
  end

  scenario 'pending -> publish' do
    publisher = create(:publisher)
    opportunity = create_opportunity(status: 'pending')

    login_as(publisher)
    visit '/export-opportunities/admin/opportunities'
    click_on opportunity.title
    expect(page).to have_text('Pending')
    click_on 'Publish'
    expect(page).to have_text('This opportunity has been published')
    expect(page).to have_text('Publish')
    expect(opportunity.reload.status).to eq 'publish'
  end

  scenario 'uploaders cannot unpublish content' do
    uploader = create(:uploader)
    opportunity = create_opportunity(status: 'publish')

    login_as(uploader)
    visit '/export-opportunities/admin/opportunities'
    click_on opportunity.title
    expect(page).to have_no_button('Unpublish')
  end

  scenario 'publishers can unpublish content' do
    publisher = create(:publisher)
    opportunity = create_opportunity(status: 'publish')

    login_as(publisher)
    visit '/export-opportunities/admin/opportunities'
    click_on opportunity.title
    expect(page).to have_button('Unpublish')
  end

  scenario 'admins can unpublish content' do
    admin = create(:admin)
    opportunity = create_opportunity(status: 'publish')

    login_as(admin)
    visit '/export-opportunities/admin/opportunities'
    click_on opportunity.title
    expect(page).to have_button('Unpublish')
  end

  scenario 'publish -> pending' do
    publisher = create(:publisher)
    opportunity = create_opportunity(status: 'publish')

    login_as(publisher)
    visit '/export-opportunities/admin/opportunities'
    click_on opportunity.title
    expect(page).to have_text('Publish')
    click_on 'Unpublish'
    expect(page).to have_text('This opportunity has been set to pending')
    expect(page).to have_text('Pending')
    expect(opportunity.reload.status).to eq 'pending'
  end

  scenario 'publishing and republishing an opportunity' do
    publisher = create(:publisher)
    opportunity = create_opportunity(status: 'pending')

    # Select the opportunity from list
    login_as(publisher)
    visit admin_opportunities_path
    click_on opportunity.title

    expect(current_path).to eq(admin_opportunity_path(opportunity))
    expect(find('.status').text).to include('Status Pending')
    expect(opportunity.reload.status).to eq('pending')

    click_on 'Publish'

    # Now go back and see if it was published.
    visit admin_opportunities_path
    click_on opportunity.title

    expect(current_path).to eq(admin_opportunity_path(opportunity))
    expect(find('.status').text).to include('Status Published')
    expect(opportunity.reload.status).to eq('publish')

    click_on 'Unpublish'

    # Now go back and see if it is unpublished again.
    visit admin_opportunities_path
    click_on opportunity.title

    expect(current_path).to eq(admin_opportunity_path(opportunity))
    expect(find('.status').text).to include('Status Pending')
    expect(opportunity.reload.status).to eq('pending')
  end

  scenario 'publishing when opportunity is invalid' do
    publisher = create(:publisher)
    invalid_opportunity = build(:opportunity, status: 'pending', title: nil, slug: 'slug-is-valid')
    invalid_opportunity.save(validate: false)

    login_as(publisher)
    visit admin_opportunity_path(invalid_opportunity)
    click_on 'Publish'

    expect(page).to have_text('problem')
    expect(invalid_opportunity.reload.status).to eq('pending')
    expect(page).to have_text('Pending')
  end

  def create_opportunity(status:, description: 'Replicants are like any other machine. They’re either a benefit or a hazard. If they’re a benefit, it’s not my problem.')
    Opportunity.create! \
      title: 'A chance to begin again in a golden land of opportunity and adventure',
      slug: 'a-chance-to-begin-again-in-a-golden-land-of-opportunity-and-adventure',
      teaser: 'A new life awaits you in the off-world colonies!',
      response_due_on: 1.week.from_now,
      description: description,
      contacts: [
        Contact.new(name: 'Jane Doe', email: 'jane.doe@example.com'),
        Contact.new(name: 'Joe Bloggs', email: 'joe.bloggs@example.com'),
      ],
      service_provider: create_service_provider('Italy Rome'),
      status: status,
      author: create(:uploader),
      source: :post
  end

  def create_service_provider(name)
    ServiceProvider.create! \
      name: name
  end
end
