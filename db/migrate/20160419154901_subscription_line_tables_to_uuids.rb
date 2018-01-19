class SubscriptionLineTablesToUuids < ActiveRecord::Migration[4.2]
  def change
    remove_column :countries_subscriptions, :subscription_id
    remove_column :sectors_subscriptions, :subscription_id
    remove_column :subscriptions_types, :subscription_id
    remove_column :subscriptions_values, :subscription_id

    add_column :countries_subscriptions, :subscription_id, :uuid
    add_column :sectors_subscriptions, :subscription_id, :uuid
    add_column :subscriptions_types, :subscription_id, :uuid
    add_column :subscriptions_values, :subscription_id, :uuid
  end
end
