class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.references :opportunity, null: false
      t.string :name, null: false
      t.string :email_address, null: false
    end
  end
end
