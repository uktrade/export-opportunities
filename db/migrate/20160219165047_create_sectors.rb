class CreateSectors < ActiveRecord::Migration[4.2]
  def change
    create_table :sectors do |t|
      t.integer :wordpress_id, null: false
      t.string :slug, null: false
      t.string :name, null: false
    end
  end
end
