class RemovePasswordFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :encrypted_password, :string
    remove_column :users, :reset_password_token, :string
    remove_column :users, :reset_password_sent_at, :datetime
  end

  def down
    add_column :users, :encrypted_password, :string, null: false, default: '_'
    add_column :users, :reset_password_token, :string
    add_column :users, :reset_password_sent_at, :datetime
  end
end
