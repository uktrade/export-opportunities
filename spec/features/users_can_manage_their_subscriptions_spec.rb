require 'rails_helper'

feature 'User can manage their subscriptions' do
  scenario 'view a list of all subscriptions' do
    token = SecureRandom.uuid

    user = create(:user, email: 'john@green.com')
    user_id = EncryptedParams.encrypt(user.id)

    opportunity = create(:opportunity, title: 'opportunities match by live searching', slug: 'great-opportunity', status: :publish)

    # email digest results match based on searching across published opportunities
    create(:subscription, user: user, confirmation_token: token, search_term: 'opportunities match by live searching')

    login_as(user, scope: :user)
    sleep 1

    visit '/email_notifications/' + user_id

    expect(page.body).to include(opportunity.title)
  end

  scenario 'delete all subscriptions' do
    token = SecureRandom.uuid

    user = create(:user, email: 'john@green.com')
    user_id = EncryptedParams.encrypt(user.id)

    opportunity = create(:opportunity, title: 'Great Opportunity!', slug: 'great-opportunity')
    subscription = create(:subscription, user: user, confirmation_token: token)
    create(:subscription_notification, :sent, subscription: subscription, opportunity: opportunity)

    login_as(user, scope: :user)

    visit '/email_notifications/unsubscribe_all/' + user_id

    expect(page.body).to include('You have been unsubscribed from all email alerts')
  end

  scenario 'delete all subscriptions and provide a reason for doing so' do
    token = SecureRandom.uuid

    user = create(:user, email: 'john@green.com')
    user_id = EncryptedParams.encrypt(user.id)

    opportunity = create(:opportunity, title: 'Great Opportunity!', slug: 'great-opportunity')
    subscription = create(:subscription, user: user, confirmation_token: token)
    create(:subscription_notification, :sent, subscription: subscription, opportunity: opportunity)

    login_as(user, scope: :user)

    visit '/email_notifications/unsubscribe_all/' + user_id

    expect(page.body).to include('You have been unsubscribed from all email alerts')

    # I didn't sign up for these emails
    choose 'reason_1'

    # get to the next page
    click_on 'submit'

    expect(page.body).to include('Thank you for telling us why you unsubscribed')
  end
end
