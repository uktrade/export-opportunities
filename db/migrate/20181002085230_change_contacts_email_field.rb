class ChangeContactsEmailField < ActiveRecord::Migration[5.2]
  def change
    change_column_null(:contacts, :email, true)
  end
end
