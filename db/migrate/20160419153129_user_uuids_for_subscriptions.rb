class UserUuidsForSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :subscriptions, :uuid, :uuid, default: 'uuid_generate_v4()', null: false

    change_table :subscriptions do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute 'ALTER TABLE subscriptions ADD PRIMARY KEY (id);'
  end
end
