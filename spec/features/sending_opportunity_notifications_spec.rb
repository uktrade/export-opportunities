require 'rails_helper'
require 'capybara/email/rspec'

feature 'sending opportunity notifications', :elasticsearch, :commit do
  before(:each) do
    clear_emails
  end

  scenario 'when there are matching sectors for this opportunity', sidekiq: :inline do
    skip('TODO: refactor with digest email')
    publisher = create(:publisher)
    login_as(publisher)

    sectors = create_list(:sector, 2)
    opportunity = create(:opportunity, title: 'Bodger and Bazzle', sectors: sectors, author: publisher, status: :pending)

    first_subscription = create(:subscription, search_term: 'bazzle', sectors: [sectors.sample])
    second_subscription = create(:subscription, search_term: 'bazzle', sectors: sectors)

    visit admin_opportunity_path(opportunity)
    sleep 1
    click_on 'Publish'

    open_email(first_subscription.email)
    expect(current_email).to have_content(opportunity.title)

    open_email(second_subscription.email)
    expect(current_email).to have_content(opportunity.title)
  end

  scenario 'when there are bulk subscriptions', sidekiq: :inline do
    skip('TODO: refactor with digest email')
    admin = create(:admin)
    login_as(admin)

    sectors = create_list(:sector, 2)
    opportunity = create(:opportunity, sectors: sectors, author: admin, status: :pending, title: 'Export rain to Spain')

    bulk_subscription = create(:subscription, search_term: nil)

    visit admin_opportunity_path(opportunity)
    click_on 'Publish'

    open_email(bulk_subscription.email)
    expect(current_email).to have_content('Export rain to Spain')
  end
end
