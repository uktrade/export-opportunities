class RemoveEmailUniqueIndexOnUsers < ActiveRecord::Migration
  disable_ddl_transaction!

  def up
    remove_index :users, :email
    add_index :users, :email, algorithm: :concurrently
  end

  def down
    remove_index :users, :email
    add_index :users, :email, algorithm: :concurrently, unique: true
  end
end
