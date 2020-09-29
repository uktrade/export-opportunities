class ChangeEditorNullConstraint < ActiveRecord::Migration[6.0]
  def change
    change_column_null :editors, :encrypted_password, true
  end
end
