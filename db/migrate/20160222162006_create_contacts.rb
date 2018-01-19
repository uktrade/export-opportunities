class CreateContacts < ActiveRecord::Migration[4.2]
  def change
    create_table :contacts do |t|
      t.references :opportunity, null: false
      t.string :name, null: false
      t.string :email_address, null: false
    end
  end
end
