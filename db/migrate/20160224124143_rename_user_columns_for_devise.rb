class RenameUserColumnsForDevise < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.rename :email_address, :email
      t.rename :password, :encrypted_password
    end
  end
end
