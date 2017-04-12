class AddUserIdToFeedbackOptOuts < ActiveRecord::Migration
  def change
    add_column :feedback_opt_outs, :user_id, :uuid
  end
end
