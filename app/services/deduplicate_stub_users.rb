class DeduplicateStubUsers
  def call
    duplicated_user_accounts = User.where(email: User.group(:email).having('count(email) > 1').count.keys)
    unique_email_addresses_for_duplicate_user_accounts = duplicated_user_accounts.map(&:email).uniq

    unique_email_addresses_for_duplicate_user_accounts.each do |email|
      chosen_user = User.where(email: email).where.not(provider: nil, uid: nil).first

      if chosen_user
        users = User.where(email: email).where.not(id: chosen_user.id)
      else
        users = User.where(email: email)
        chosen_user = users.first
      end

      reassign_enquiries!(users: users, chosen_user: chosen_user)
      reassign_subscriptions!(users: users, chosen_user: chosen_user)

      User.where(email: email).where.not(id: chosen_user.id).destroy_all
    end
  end

  def reassign_enquiries!(users:, chosen_user:)
    enquiries = users.flat_map(&:enquiries)

    enquiries.each do |enquiry|
      enquiry.update_column(:user_id, chosen_user.id)
    end
  end

  def reassign_subscriptions!(users:, chosen_user:)
    subscriptions = users.flat_map(&:subscriptions)

    subscriptions.each do |subscription|
      subscription.update_column(:user_id, chosen_user.id)
    end
  end
end
