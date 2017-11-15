class AddSessionLimiterToEditors < ActiveRecord::Migration
  def change
    add_column :editors, :unique_session_id, :string, limit: 20
  end
end
