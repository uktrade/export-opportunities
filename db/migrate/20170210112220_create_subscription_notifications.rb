class CreateSubscriptionNotifications < ActiveRecord::Migration[4.2]
  def change
    create_table :subscription_notifications do |t|
      t.uuid :opportunity_id, index: true, foreign_key: true
      t.uuid :subscription_id, index: true, foreign_key: true
      t.boolean :sent
      t.timestamps
    end
  end
end
