class RemoveNullContraintOnWordPressIdFromUsers < ActiveRecord::Migration[4.2]
  def change
    change_column_null(:users, :wordpress_id, true)
  end
end
