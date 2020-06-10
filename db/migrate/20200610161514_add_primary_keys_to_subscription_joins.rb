class AddPrimaryKeysToSubscriptionJoins < ActiveRecord::Migration[6.0]
  def change
    add_column :countries_subscriptions, :id, :primary_key
    add_column :sectors_subscriptions, :id, :primary_key
    add_column :subscriptions_types, :id, :primary_key
    add_column :subscriptions_values, :id, :primary_key
  end
end
