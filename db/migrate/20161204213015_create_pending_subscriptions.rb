class CreatePendingSubscriptions < ActiveRecord::Migration[4.2]
  def change
    create_table :pending_subscriptions, id: :uuid do |t|
      t.text :query_params
      t.uuid :subscription_id, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
