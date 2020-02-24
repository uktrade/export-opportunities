class AddSsoHashedUuidToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :sso_hashed_uuid, :string
  end
end
