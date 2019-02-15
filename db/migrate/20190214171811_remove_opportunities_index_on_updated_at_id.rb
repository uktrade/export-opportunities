class RemoveOpportunitiesIndexOnUpdatedAtId < ActiveRecord::Migration[5.2]
  def change
    remove_index :opportunities, [:updated_at, :id]
  end
end
