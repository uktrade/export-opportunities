class CreateOpportunitySensitivityTermChecks < ActiveRecord::Migration[5.1]
  def change
    create_table :opportunity_sensitivity_term_checks do |t|
      t.belongs_to :opportunity_sensitivity_check, index: {name: 'index_opp_sens_checks_id'}, foreign_key: true
      t.integer :index
      t.integer :original_index
      t.integer :list_id
      t.string :term
    end
  end
end
