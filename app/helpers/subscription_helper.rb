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
    params.require(:subscription).permit(:title, :s, sectors: [], countries: [], types: [], values: [], cpv: [])
  end

  # Shared between:
  # SubscriptionsController#create
  # PendingSubscriptionsController#update
  def create_subscription(params, content)
    clean_params = Search.new(params) # Does not run; cleans params

    # A single subscription has one or multiple CPVs
    form = SubscriptionForm.new(
      term: clean_params.term,
      cpvs: clean_params.spvs,
      filter: clean_params.filter
    )
    if form.valid?

      subscription = Subscription.create!(
        user: current_user,
        title: form[:title],
        search_term: form[:term],
        cpvs: form[:cpvs],
        countries: form[:countries],
        sectors: form[:sectors],
        types: form[:types],
        values: form[:values],
        confirmed_at: Time.zone.now
      )

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

  private

    def clean_cpv(params)
      params[:cpv]
    end
end
