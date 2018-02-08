class AddRaggToOpportunities < ActiveRecord::Migration[4.2]
  def change
    add_column :opportunities, :ragg, :integer, default: 0, null: false
  end
end
