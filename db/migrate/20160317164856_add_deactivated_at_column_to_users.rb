class AddDeactivatedAtColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :deactivated_at, :datetime
  end
end
