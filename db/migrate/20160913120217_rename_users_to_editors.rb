class RenameUsersToEditors < ActiveRecord::Migration[4.2]
  def change
    rename_table :users, :editors
  end
end
