class AddEmailIndexToSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_index :subscriptions, :email
  end
end
