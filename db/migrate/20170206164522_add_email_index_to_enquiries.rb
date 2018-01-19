class AddEmailIndexToEnquiries < ActiveRecord::Migration[4.2]
  def change
    add_index :enquiries, :email_address
  end
end
