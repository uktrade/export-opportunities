require 'rails_helper'

feature "User viewing opportunity notification email" do
  scenario 'can unsubscribed from' do
    user = create(:user, email: 'test@example.com')
    subscription = create(:subscription, user: user)
    assert_nil subscription.unsubscribed_at

    OpportunityMailer.send_opportunity(user, {count: 2, subscriptions: {}}).deliver_now!

    email = ActionMailer::Base.deliveries.last
    path = ENV["DOMAIN"] + delete_email_notifications_path(user.unsubscription_token)
    assert email.html_part.body.include?(path)
    assert email.text_part.body.include?(path)
    visit(path)
    subscription.reload
    assert subscription.unsubscribed_at != nil
  end

  scenario 'can unsubscribed from with old encrypted ID method' do
    user = create(:user, email: 'test@example.com')
    subscription = create(:subscription, user: user)
    assert_nil subscription.unsubscribed_at

    OpportunityMailer.send_opportunity(user, {count: 2, subscriptions: {}}).deliver_now!

    encrypted_id = EncryptedParams.encrypt(user.id)
    email = ActionMailer::Base.deliveries.last
    path = ENV["DOMAIN"] + delete_email_notifications_path(encrypted_id)
    visit(path)
    subscription.reload
    assert subscription.unsubscribed_at != nil
  end
end