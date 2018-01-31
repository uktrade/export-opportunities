class RemoveConfirmationFromUsers < ActiveRecord::Migration[4.2]
  def change
    remove_columns :users, :confirmation_token, :confirmed_at, :confirmation_sent_at
  end
end
