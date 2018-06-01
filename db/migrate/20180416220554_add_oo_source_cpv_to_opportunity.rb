class AddOoSourceCpvToOpportunity < ActiveRecord::Migration[5.1]
  def change
    add_column :opportunities, :industry_scheme, :text
    add_column :opportunities, :industry_id, :integer
  end
end
