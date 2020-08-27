class AddOmniauthToEditors < ActiveRecord::Migration[6.0]
  def change
    add_column :editors, :provider, :string
    add_index :editors, :provider
    add_column :editors, :uid, :string
    add_index :editors, :uid
  end
end
