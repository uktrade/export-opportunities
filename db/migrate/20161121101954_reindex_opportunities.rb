class ReindexOpportunities < ActiveRecord::Migration
  def up
    add_column :opportunities, :tsv_temp, :boolean

    Opportunity.find_each { |o| o.update_column(:tsv_temp, true) }

    remove_column :opportunities, :tsv_temp
  end

  def down
    # NOOP
  end
end
