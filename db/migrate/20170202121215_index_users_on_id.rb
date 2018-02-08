class IndexUsersOnId < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def change
    add_index :users, :id, algorithm: :concurrently
  end
end
