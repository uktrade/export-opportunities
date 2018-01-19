class RemoveArchivedFromSubscriptions < ActiveRecord::Migration[4.2]
  def change
    remove_column :subscriptions, :archived
  end
end
