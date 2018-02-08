class AddArchivedAtToSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :subscriptions, :archived_at, :datetime, null: true
  end
end
