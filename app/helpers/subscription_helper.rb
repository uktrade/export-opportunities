module SubscriptionHelper
  def subscriptions_path_for_current_user
    if current_user
      subscriptions_path
    else
      pending_subscriptions_path
    end
  end
end
