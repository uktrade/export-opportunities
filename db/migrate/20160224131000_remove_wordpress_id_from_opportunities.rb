class RemoveWordpressIdFromOpportunities < ActiveRecord::Migration
  def change
    remove_column :opportunities, :wordpress_id, :integer, null: false
  end
end
