class AddUuidToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :uuid, :uuid
  end
end
