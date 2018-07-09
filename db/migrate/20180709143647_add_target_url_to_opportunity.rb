class AddTargetUrlToOpportunity < ActiveRecord::Migration[5.1]
  def change
    add_column :opportunities, :target_url, :text
  end
end
