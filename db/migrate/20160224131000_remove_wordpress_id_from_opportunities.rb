class RemoveWordpressIdFromOpportunities < ActiveRecord::Migration[4.2]
  def change
    remove_column :opportunities, :wordpress_id, :integer, null: false
  end
end
