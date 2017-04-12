class AddUserIdIndexToFeedbackOptOuts < ActiveRecord::Migration
  def change
    add_index :feedback_opt_outs, :user_id
  end
end
