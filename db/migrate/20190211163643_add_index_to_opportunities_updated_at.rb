class AddIndexToOpportunitiesUpdatedAt < ActiveRecord::Migration[5.2]
  def change
    add_index :opportunities, [:updated_at, :id]
  end
end
