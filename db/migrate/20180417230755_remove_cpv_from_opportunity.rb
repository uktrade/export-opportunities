class RemoveCpvFromOpportunity < ActiveRecord::Migration[5.1]
  def change
    remove_column :opportunities, :industry_scheme, :text
    remove_column :opportunities, :industry_id, :integer
  end
end
