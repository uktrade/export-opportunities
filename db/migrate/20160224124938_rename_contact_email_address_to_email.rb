class RenameContactEmailAddressToEmail < ActiveRecord::Migration
  def change
    change_table :contacts do |t|
      t.rename :email_address, :email
    end
  end
end
