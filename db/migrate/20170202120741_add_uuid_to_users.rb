class AddUuidToUsers < ActiveRecord::Migration
  def change
    add_column :users, :uuid, :uuid
  end
end
