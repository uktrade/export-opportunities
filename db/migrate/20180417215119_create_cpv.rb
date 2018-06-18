class CreateCpv < ActiveRecord::Migration[5.1]
  def change
    create_table :opportunity_cpvs do |t|
      t.uuid :opportunity_id, null: false
      t.integer :industry_id
      t.string :industry_scheme
      t.timestamps
    end
    add_index :opportunity_cpvs, :opportunity_id
  end
end
