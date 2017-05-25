class AddRaggToOpportunities < ActiveRecord::Migration
  def change
    add_column :opportunities, :ragg, :integer, default: 0, null: false
  end
end
