class ChangeCpvIndustryIdToString < ActiveRecord::Migration[5.2]
  def change
    change_column :opportunity_cpvs, :industry_id, :string
  end
end
