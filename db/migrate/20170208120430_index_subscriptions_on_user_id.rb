class IndexSubscriptionsOnUserId < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :subscriptions, :user_id, algorithm: :concurrently
  end
end
