class AddEmailIndexToEnquiries < ActiveRecord::Migration
  def change
    add_index :enquiries, :email_address
  end
end
