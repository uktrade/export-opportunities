class IndexEnquiriesOnUserId < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :enquiries, :user_id, algorithm: :concurrently
  end
end
