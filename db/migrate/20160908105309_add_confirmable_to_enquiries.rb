class AddConfirmableToEnquiries < ActiveRecord::Migration[4.2]
  def change
    add_column :enquiries, :confirmation_token, :string
    add_column :enquiries, :confirmed_at, :datetime
    add_column :enquiries, :confirmation_sent_at, :datetime
    add_index :enquiries, :confirmation_token, unique: true
  end
end
