module SubscriptionHelper
  # User needs to be logged in otherwise we have to go through
  # SSO and need to employ the pending subscription mechanism.
  def create_subscription_path
    if current_user
      subscriptions_path
    else
      pending_subscriptions_path
    end
  end

  def subscription_params
    params.require(:subscription).permit(query: [:title, :search_term, sectors: [], countries: [], types: [], values: []])
  end

  # Shared between:
  # SubscriptionsController#create
  # PendingSubscriptionsController#update
  def create_subscription(params, content)
    subscription_form = SubscriptionForm.new(params)
    subscription = CreateSubscription.new.call(subscription_form, current_user)
    if subscription_form.valid?
      yield(subscription) if block_given?
      render 'subscriptions/create', layout: 'notification', locals: {
        subscriptions: Subscription.where(user_id: current_user.id).where(unsubscribed_at: nil),
        subscription: SubscriptionPresenter.new(subscription),
        content: content['create'],
      }
    else
      redirect_to opportunities_path(s: subscription_form.search_term), alert: subscription_form.errors.full_messages
    end
  end
end
