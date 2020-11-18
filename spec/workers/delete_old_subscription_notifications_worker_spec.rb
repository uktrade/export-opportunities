require 'rails_helper'

RSpec.describe DeleteOldSubscriptionNotificationsWorker do

  subject { DeleteOldSubscriptionNotificationsWorker.new }

  it 'deletes subscription notifications older than 30 days' do
    SubscriptionNotification.delete_all
    create(:subscription_notification)
    travel_to(2.months.ago) { create(:subscription_notification) }

    expect { subject.perform }
      .to change { SubscriptionNotification.count }.from(2).to(1)
    expect(SubscriptionNotification.where('created_at < ?', 1.month.ago))
      .to be_empty
  end
end
