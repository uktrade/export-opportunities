require 'rails_helper'

RSpec.describe DeleteOldSubscriptionNotificationsWorker do

  it 'deletes subscription notifications older than 30 days' do
    SubscriptionNotification.destroy_all
    create(:subscription_notification)
    old_notification = create(:subscription_notification)
    old_notification.update_columns(
      updated_at: 2.months.ago,
      created_at: 2.months.ago
    )

    expect(SubscriptionNotification.count).to eq(2)
    DeleteOldSubscriptionNotificationsWorker.new.perform
    expect(SubscriptionNotification.count).to eq(1)
  end

end
