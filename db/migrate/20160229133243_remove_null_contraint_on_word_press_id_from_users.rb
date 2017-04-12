class RemoveNullContraintOnWordPressIdFromUsers < ActiveRecord::Migration
  def change
    change_column_null(:users, :wordpress_id, true)
  end
end
