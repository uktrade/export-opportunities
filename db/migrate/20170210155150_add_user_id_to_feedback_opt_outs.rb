class AddUserIdToFeedbackOptOuts < ActiveRecord::Migration[4.2]
  def change
    add_column :feedback_opt_outs, :user_id, :uuid
  end
end
