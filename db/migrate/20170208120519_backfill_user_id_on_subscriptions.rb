class BackfillUserIdOnSubscriptions < ActiveRecord::Migration
  def up
    # Ensure we have the latest schema
    Subscription.reset_column_information

    users_hash = User.pluck(:email, :id).to_h
    emails = Subscription.select(:email).distinct.pluck(:email)

    emails.each do |email|
      Subscription.where(email: email).update_all(user_id: users_hash[email.downcase])
    end

    change_column_null :subscriptions, :email, true
    rename_column :subscriptions, :email, :legacy_email
  end

  def down
    Subscription.update_all(user_id: nil)

    rename_column :subscriptions, :legacy_email, :email
    change_column_null :subscriptions, :email, false
  end
end
