class RenameContactEmailAddressToEmail < ActiveRecord::Migration[4.2]
  def change
    change_table :contacts do |t|
      t.rename :email_address, :email
    end
  end
end
