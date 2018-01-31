class AddConfirmableToSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :subscriptions, :confirmation_token, :string
    add_column :subscriptions, :confirmed_at, :datetime
    add_column :subscriptions, :confirmation_sent_at, :datetime
    add_index :subscriptions, :confirmation_token, unique: true
  end
end
