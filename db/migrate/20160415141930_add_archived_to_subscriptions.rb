class AddArchivedToSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :subscriptions, :archived, :boolean, default: false
  end
end
