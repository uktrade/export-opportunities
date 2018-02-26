class CreateOpportunitySensitivityChecks < ActiveRecord::Migration[5.1]
  def change
    create_table :opportunity_sensitivity_checks do |t|
      t.string :error_id
      t.string :submitted_text
      t.boolean :review_recommended
      t.float :category1_score
      t.float :category2_score
      t.float :category3_score
      t.string :language
      t.string :custom_terms_matched
      t.integer :custom_list_id
      t.uuid :opportunity_id, null: false
      t.timestamps
    end
    add_index :opportunity_sensitivity_checks, :opportunity_id
  end
end
