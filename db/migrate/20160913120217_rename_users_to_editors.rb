class RenameUsersToEditors < ActiveRecord::Migration
  def change
    rename_table :users, :editors
  end
end
