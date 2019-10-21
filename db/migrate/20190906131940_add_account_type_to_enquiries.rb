class AddAccountTypeToEnquiries < ActiveRecord::Migration[5.2]
  def change
    add_column :enquiries, :account_type, :string
  end
end
