class IndexEnquiriesOnUserId < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def change
    add_index :enquiries, :user_id, algorithm: :concurrently
  end
end
