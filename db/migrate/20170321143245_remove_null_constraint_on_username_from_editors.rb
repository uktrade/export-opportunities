class RemoveNullConstraintOnUsernameFromEditors < ActiveRecord::Migration
  def change
    change_column_null(:editors, :username, true)
  end
end
