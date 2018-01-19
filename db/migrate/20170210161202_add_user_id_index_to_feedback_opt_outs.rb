class AddUserIdIndexToFeedbackOptOuts < ActiveRecord::Migration[4.2]
  def change
    add_index :feedback_opt_outs, :user_id
  end
end
