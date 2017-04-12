class AddArchivedToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :archived, :boolean, default: false
  end
end
