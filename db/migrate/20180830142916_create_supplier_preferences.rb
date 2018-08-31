class CreateSupplierPreferences < ActiveRecord::Migration[5.2]
  def change
    create_table :supplier_preferences do |t|
      t.string :slug, null: false
      t.string :name, null: false
    end
    create_table :opportunities_supplier_preferences do |t|
      t.integer :supplier_preference_id
      t.uuid :opportunity_id
    end

    add_index(:opportunities_supplier_preferences, [:opportunity_id, :supplier_preference_id], name: 'opportunity_supplier_index')
  end
end
