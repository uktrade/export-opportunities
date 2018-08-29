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

  scenario 'delete all subscriptions having no inactive subscriptions' do
    token = SecureRandom.uuid
    another_token = SecureRandom.uuid

    user = create(:user, email: 'john@green.com')
    user_id = EncryptedParams.encrypt(user.id)

    opportunity = create(:opportunity, title: 'Great Opportunity!', slug: 'great-opportunity')
    subscription = create(:subscription, user: user, confirmation_token: token)
    another_subscription = create(:subscription, user: user, confirmation_token: another_token)
    create(:subscription_notification, :sent, subscription: subscription, opportunity: opportunity)

    login_as(user, scope: :user)

    visit '/email_notifications/unsubscribe_all/' + user_id

    expect(page.body).to include('You have been unsubscribed from all email alerts')

    # fetch again subscriptions from DB to make sure that it's now unsubscribed
    subscription.reload
    another_subscription.reload

    expect(another_subscription.unsubscribed_at).to_not eq(nil)
    expect(subscription.unsubscribed_at).to_not eq(nil)
  end

  scenario 'delete all subscriptions having some inactive subscriptions' do
    token = SecureRandom.uuid
    another_token = SecureRandom.uuid

    user = create(:user, email: 'john@green.com')
    user_id = EncryptedParams.encrypt(user.id)
    unsubscription_timestamp = Time.zone.now - 1.month

    opportunity = create(:opportunity, title: 'Great Opportunity!', slug: 'great-opportunity')
    subscription = create(:subscription, user: user, confirmation_token: token)
    subscription_unsubscribed = create(:subscription, user: user, confirmation_token: another_token, unsubscribed_at: unsubscription_timestamp)
    create(:subscription_notification, :sent, subscription: subscription, opportunity: opportunity)

    login_as(user, scope: :user)

    visit '/email_notifications/unsubscribe_all/' + user_id

    expect(page.body).to include('You have been unsubscribed from all email alerts')
    expect(subscription_unsubscribed.unsubscribed_at).to eq(unsubscription_timestamp)

    # fetch again subscription from DB to make sure that it's now unsubscribed
    subscription.reload
    expect(subscription.unsubscribed_at).to_not eq(nil)
  end
end
