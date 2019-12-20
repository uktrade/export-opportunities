class AddCpvToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :cpv_industry_id, :string
  end
end
