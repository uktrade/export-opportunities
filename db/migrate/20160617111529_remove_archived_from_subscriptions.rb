class RemoveArchivedFromSubscriptions < ActiveRecord::Migration
  def change
    remove_column :subscriptions, :archived
  end
end
