class AddArchivedAtToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :archived_at, :datetime, null: true
  end
end
