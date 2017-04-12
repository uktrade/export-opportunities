class RenameArchivedAtToUnsubscribedAtInSubscriptions < ActiveRecord::Migration
  def change
    rename_column :subscriptions, :archived_at, :unsubscribed_at
  end
end
