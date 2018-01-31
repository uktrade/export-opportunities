class CreateUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :users do |t|
      t.integer :wordpress_id, null: false
      t.string :username, null: false
      t.string :password, null: false
      t.string :email_address, null: false
      t.string :name, null: false
      t.timestamps
    end
  end
end
