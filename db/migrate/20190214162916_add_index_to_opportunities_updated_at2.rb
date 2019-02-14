class AddIndexToOpportunitiesUpdatedAt2 < ActiveRecord::Migration[5.2]
  def change
    add_index :opportunities, [:status, :response_due_on, :updated_at, :id], :name => 'activity_stream_index'
  end
end
