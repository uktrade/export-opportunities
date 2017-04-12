class CreateOpportunityComments < ActiveRecord::Migration
  def change
    create_table :opportunity_comments, id: :uuid do |t|
      t.string :message, null: false
      t.uuid :opportunity_id, null: false
      t.integer :author_id, null: false
      t.timestamps
    end

    add_index :opportunity_comments, :opportunity_id
    add_index :opportunity_comments, :author_id
  end
end
