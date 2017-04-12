class UserUuidsForSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :uuid, :uuid, default: 'uuid_generate_v4()', null: false

    change_table :subscriptions do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute 'ALTER TABLE subscriptions ADD PRIMARY KEY (id);'
  end
end
