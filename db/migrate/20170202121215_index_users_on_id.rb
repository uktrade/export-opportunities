class IndexUsersOnId < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :users, :id, algorithm: :concurrently
  end
end
