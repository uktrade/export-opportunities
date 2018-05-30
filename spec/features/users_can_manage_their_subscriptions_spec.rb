require 'rails_helper'

feature 'User can manage their subscriptions' do
  scenario 'view a list of all subscriptions' do
    token = SecureRandom.uuid

    user = create(:user, email: 'john@green.com')
    user_id = EncryptedParams.encrypt(user.id)

    opportunity = create(:opportunity, title: 'Great Opportunity!', slug: 'great-opportunity')
    subscription = create(:subscription, user: user, confirmation_token: token)
    create(:subscription_notification, :sent, subscription: subscription, opportunity: opportunity)

    login_as(user, scope: :user)

    visit '/email_notifications/' + user_id
    expect(page.body).to include(opportunity.title)
  end

  scenario 'delete all subscriptions' do
    token = SecureRandom.uuid

    user = create(:user, email: 'john@green.com')
    user_id = EncryptedParams.encrypt(user.id)

    opportunity = create(:opportunity, title: 'Great Opportunity!', slug: 'great-opportunity')
    subscription = create(:subscription, user: user, confirmation_token: token)
    subscription_notification = create(:subscription_notification, :sent, subscription: subscription, opportunity: opportunity)

    login_as(user, scope: :user)

    visit '/email_notifications/unsubscribe_all/' + user_id

    expect(page.body).to include('deleted')
  end

  scenario 'delete all subscriptions and provide a reason for doing so' do
    token = SecureRandom.uuid

    user = create(:user, email: 'john@green.com')
    user_id = EncryptedParams.encrypt(user.id)

    opportunity = create(:opportunity, title: 'Great Opportunity!', slug: 'great-opportunity')
    subscription = create(:subscription, user: user, confirmation_token: token)
    subscription_notification = create(:subscription_notification, :sent, subscription: subscription, opportunity: opportunity)

    login_as(user, scope: :user)

    visit '/email_notifications/unsubscribe_all/' + user_id

    expect(page.body).to include('deleted')

    # select reason
    # click on submit
    # expect new page to have some content that we know should only be there if request is successful
  end

  scenario 'view a list of all subscription notifications in opportunities filter view' do
    token = SecureRandom.uuid

    user = create(:user, email: 'john@green.com')
    user_id = EncryptedParams.encrypt(user.id)

    opportunity = create(:opportunity, title: 'Great Opportunity!', slug: 'great-opportunity')
    subscription = create(:subscription, user: user, confirmation_token: token)
    subscription_notification = create(:subscription_notification, :sent, subscription: subscription, opportunity: opportunity)

    login_as(user, scope: :user)

    visit '/poc/opportunities/digest/' + user_id
    
    expect(page.body).to include(opportunity.title)
    expect(page.body).to include(subscription.search_term)
  end
end
