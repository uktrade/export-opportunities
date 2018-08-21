class AddIndexToEnquriesCreatedAt < ActiveRecord::Migration[5.2]
  def change
    add_index :enquiries, [:created_at, :id]
  end
end
