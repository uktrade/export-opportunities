class RemoveActivityStreamOpportunitiesIndex < ActiveRecord::Migration[5.2]
  def change
    remove_index :opportunities, name: :activity_stream_index
  end
end
