class AddOcidToOpportunity < ActiveRecord::Migration[5.1]
  def change
    add_column :opportunities, :ocid, :text
    add_index :opportunities, :ocid, unique: true
  end
end
