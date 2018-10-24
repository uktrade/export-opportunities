class ChangeOpportunityTenderValue < ActiveRecord::Migration[5.2]
  def up
    change_column :opportunities, :tender_value, :bigint
  end

  def down
    change_column :opportunities, :tender_value, :integer
  end
end
