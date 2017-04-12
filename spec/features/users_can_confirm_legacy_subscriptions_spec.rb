require 'rails_helper'
require 'capybara/email/rspec'

RSpec.feature 'Users can confirm legacy subscriptions' do
  scenario 'when clicking the confirmation link in the email for the first time' do
    user = create(:user, :stub, email: 'test@example.com')
    subscription = create(:subscription, :unconfirmed, user: user, search_term: 'food')

    # NB: Email template has been removed, so visit the link
    # that was previously present in those emails
    visit subscription_confirmation_url(subscription)

    expect(page).to have_content('Thank you for subscribing to e-mail alerts')

    subscription.reload
    expect(subscription).to be_confirmed
  end

  scenario 'when clicking the confirmation link in the email more than once' do
    user = create(:user, :stub, email: 'test@example.com')
    subscription = create(:subscription, :unconfirmed, user: user, search_term: 'food')

    visit subscription_confirmation_url(subscription)

    expect(page.status_code).to eq(202)

    subscription.reload

    expect(subscription).to be_confirmed

    visit subscription_confirmation_url(subscription)

    expect(page.status_code).to eq(202)
    expect(page).to have_content('Thank you for subscribing to e-mail alerts')
  end
end
