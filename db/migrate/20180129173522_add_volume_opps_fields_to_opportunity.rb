class AddVolumeOppsFieldsToOpportunity < ActiveRecord::Migration[5.1]
  def change
    add_column :opportunities, :source, :integer, default: :post
    add_column :opportunities, :language, :text
    add_column :opportunities, :buyer, :text
    add_column :opportunities, :tender_value, :integer, default: nil
    add_column :opportunities, :tender_content, :json
  end
end
