class AddDeactivatedAtColumnToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :deactivated_at, :datetime
  end
end
