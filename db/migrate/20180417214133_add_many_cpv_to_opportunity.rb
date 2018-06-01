class AddManyCpvToOpportunity < ActiveRecord::Migration[5.1]
  def change
    add_column :opportunities, :cpv_id, :integer
    add_index  :opportunities, :cpv_id
  end
end
