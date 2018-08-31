class CreateSupplierPreferences < ActiveRecord::Migration[5.2]
  def change
    create_table :supplier_preferences do |t|
      t.string :slug, null: false
      t.string :name, null: false
    end
    create_table :opportunities_supplier_preferences do |t|
      t.integer :supplier_preference_id
      t.uuid :opportunity_id
      t.index :opportunity_id, name: 'opportunity_id_index'
      t.index :supplier_preference_id, name: 'supplier_preference_id_index'
    end
  end
end
