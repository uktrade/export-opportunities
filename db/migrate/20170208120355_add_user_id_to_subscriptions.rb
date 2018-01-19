class AddUserIdToSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :subscriptions, :user_id, :uuid
  end
end
