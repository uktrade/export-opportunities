class CreateOpportunityChecks < ActiveRecord::Migration[5.1]
  def change
    create_table :opportunity_checks do |t|
      t.string :error_id
      t.integer :offset
      t.integer :length
      t.string :submitted_text
      t.string :offensive_term
      t.string :suggested_term
      t.integer :score
      t.uuid :opportunity_id, null: false
      t.timestamps
    end
    add_index :opportunity_checks, :opportunity_id
    add_index :opportunity_checks, :error_id
  end
end
