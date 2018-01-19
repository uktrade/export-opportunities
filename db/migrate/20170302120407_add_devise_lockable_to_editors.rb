class AddDeviseLockableToEditors < ActiveRecord::Migration[4.2]
  def change
    add_column :editors, :failed_attempts, :integer, default: 0, null: false # Only if lock strategy is :failed_attempts
    add_column :editors, :unlock_token, :string # Only if unlock strategy is :email or :both
    add_column :editors, :locked_at, :datetime

    add_index :editors, :unlock_token, unique: true
  end
end
