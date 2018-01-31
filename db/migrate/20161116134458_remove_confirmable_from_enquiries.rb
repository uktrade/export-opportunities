class RemoveConfirmableFromEnquiries < ActiveRecord::Migration[4.2]
  def change
    remove_column :enquiries, :confirmation_token, :string
    remove_column :enquiries, :confirmed_at, :datetime
    remove_column :enquiries, :confirmation_sent_at, :datetime
    # This is removed with the column
    # remove_index :enquiries, :confirmation_token
  end
end
