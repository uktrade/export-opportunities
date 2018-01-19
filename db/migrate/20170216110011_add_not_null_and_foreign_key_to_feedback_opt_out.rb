class AddNotNullAndForeignKeyToFeedbackOptOut < ActiveRecord::Migration[4.2]
  def change
    change_column_null :feedback_opt_outs, :user_id, false
    add_foreign_key :feedback_opt_outs, :users
  end
end
