class AddIndexToSubscriptionNotificationsCreatedAt < ActiveRecord::Migration[6.0]
  def change
    add_index :subscription_notifications, :created_at
  end
end
