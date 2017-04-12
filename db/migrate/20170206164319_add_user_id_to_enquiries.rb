class AddUserIdToEnquiries < ActiveRecord::Migration
  def change
    add_column :enquiries, :user_id, :uuid
  end
end
