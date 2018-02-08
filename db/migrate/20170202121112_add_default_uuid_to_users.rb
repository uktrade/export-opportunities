class AddDefaultUuidToUsers < ActiveRecord::Migration[4.2]
  def change
    change_column_default :users, :uuid, 'uuid_generate_v4()'
  end
end
