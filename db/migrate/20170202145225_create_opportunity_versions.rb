class CreateOpportunityVersions < ActiveRecord::Migration[4.2]
  def change
    create_table :opportunity_versions do |t|
      t.string   :item_type
      t.uuid     :item_id,   null: false
      t.string   :event,     null: false
      t.string   :whodunnit
      t.text     :object
      t.datetime :created_at
    end
    add_index :opportunity_versions, [:item_type, :item_id]
  end
end
