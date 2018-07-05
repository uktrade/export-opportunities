require 'rails_helper'

feature 'subscribers can unsubscribe' do
  scenario 'unsubscribes a subscription with SSO' do
    user = create(:user)

    mock_sso_with(email: user.email)
    subscription = create(:subscription, user: user)

    visit "/subscriptions/unsubscribe/#{subscription.id}"

    expect(page).to have_content('unsubscribed')

    subscription.reload
    expect(subscription.unsubscribed_at).to be_between(DateTime.current - 1.hour, DateTime.current)
  end

  scenario 'unsubscribes a subscription without SSO (before 14/11/2016)' do
    user = create(:user, email: 'email@example.com', uid: nil, provider: nil)
    subscription = create(:subscription, user: user)

    visit "/subscriptions/unsubscribe/#{subscription.id}"
    expect(page.status_code).to eq(202)
    expect(page).to have_content('unsubscribed')

    subscription.reload
    expect(subscription.unsubscribed_at).to be_between(DateTime.current - 1.hour, DateTime.current)
  end

  scenario 'unsubscribes a subscription from an old email' do
    user = create(:user)
    mock_sso_with(email: user.email)
    subscription = create(:subscription, user: user, id: '8e5528f7-0c23-4ede-a491-44af02171591')
    visit '/v1/subscriptions/unsubscribe/8e5528f7-0c23-4ede-a491-44af02171591'

    expect(page.status_code).to eq(202)
    expect(page).to have_content('unsubscribed')

    subscription.reload
    expect(subscription.unsubscribed_at).to be_between(DateTime.current - 1.hour, DateTime.current)
  end
end
