class RenameArchivedAtToUnsubscribedAtInSubscriptions < ActiveRecord::Migration[4.2]
  def change
    rename_column :subscriptions, :archived_at, :unsubscribed_at
  end
end
