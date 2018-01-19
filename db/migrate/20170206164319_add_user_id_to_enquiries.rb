class AddUserIdToEnquiries < ActiveRecord::Migration[4.2]
  def change
    add_column :enquiries, :user_id, :uuid
  end
end
