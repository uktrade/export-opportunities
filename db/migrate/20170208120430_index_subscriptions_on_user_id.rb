class IndexSubscriptionsOnUserId < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def change
    add_index :subscriptions, :user_id, algorithm: :concurrently
  end
end
