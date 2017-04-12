class BackfillUserIdOnFeedbackOptOuts < ActiveRecord::Migration
  def up
    # Ensure we have the latest schema
    User.reset_column_information
    FeedbackOptOut.reset_column_information

    users_hash = User.pluck(:email, :id).to_h
    records = FeedbackOptOut.all.group_by(&:email)

    records.each do |email, grouped_records|
      user_id = users_hash.fetch(email) { raise "Couldn't find a user with email #{email}" }
      grouped_records.update_all(user_id: user_id)
    end

    change_column_null :feedback_opt_outs, :email, true
    rename_column :feedback_opt_outs, :email, :legacy_email
  end

  def down
    FeedbackOptOut.update_all(user_id: nil)

    rename_column :feedback_opt_outs, :legacy_email, :email
    change_column_null :feedback_opt_outs, :email, false
  end
end
