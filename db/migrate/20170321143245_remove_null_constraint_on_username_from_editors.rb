class RemoveNullConstraintOnUsernameFromEditors < ActiveRecord::Migration[4.2]
  def change
    change_column_null(:editors, :username, true)
  end
end
