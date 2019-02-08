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
    params.require(:subscription).permit(:title, :s, sectors: [], countries: [], types: [], values: [])
  end

  # Shared between:
  # SubscriptionsController#create
  # PendingSubscriptionsController#update
  def create_subscription(params, content)
    clean_params = Search.new(params) # Does not run; cleans params
    form = SubscriptionForm.new(
      term: clean_params.term,
      filter: clean_params.filter
    )
    subscription = CreateSubscription.new.call(form, current_user)
    if form.valid?
      yield(subscription) if block_given?
      render 'subscriptions/create', layout: 'notification', locals: {
        subscriptions: Subscription.where(user_id: current_user.id).where(unsubscribed_at: nil),
        subscription: SubscriptionPresenter.new(subscription),
        content: content['create'],
      }
    else
      redirect_to opportunities_path(s: clean_params.term), alert: subscription_form.errors.full_messages
    end
  end
end
