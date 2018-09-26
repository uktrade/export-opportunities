class AddBuyerFieldsToOpportunity < ActiveRecord::Migration[5.2]
  def change
    add_column :opportunities, :request_type, :integer, null: :false, default: 0
    add_column :opportunities, :tender, :boolean
    add_column :opportunities, :request_usage, :integer, null: :false, default: 2
    add_column :opportunities, :enquiry_interaction, :integer, null: :false, default: 0
  end
end
