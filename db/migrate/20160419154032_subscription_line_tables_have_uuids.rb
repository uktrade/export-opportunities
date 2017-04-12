class SubscriptionLineTablesHaveUuids < ActiveRecord::Migration
  def change
    change_column :countries_subscriptions, :subscription_id, :string
    change_column :sectors_subscriptions, :subscription_id, :string
    change_column :subscriptions_types, :subscription_id, :string
    change_column :subscriptions_values, :subscription_id, :string
  end
end
