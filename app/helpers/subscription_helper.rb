module SubscriptionHelper
  include ParamsHelper
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
    params.require(:subscription).permit(:title, :s, sectors: [], countries: [], types: [], values: [], cpvs: [])
  end

  # Shared between:
  # SubscriptionsController#create
  # PendingSubscriptionsController#update
  def create_subscription_from(params, content)
    term = clean_term(params[:s])
    filter = SearchFilter.new(params)
    form = SubscriptionForm.new(
      term: term,
      cpvs: clean_cpvs(params[:cpvs]),
      filter: filter
    )
    if form.valid?
      subscription = create_subscription(form.data, filter, current_user)
      yield(subscription) if block_given?
      render 'subscriptions/create', layout: 'notification', locals: {
        subscriptions: Subscription.where(user_id: current_user.id).where(unsubscribed_at: nil),
        subscription: SubscriptionPresenter.new(subscription),
        content: content['create'],
      }
    else
      redirect_to opportunities_path(s: term), alert: subscription_form.errors.full_messages
    end
  end

  private

    def create_subscription(form_data, filter, user)
      Subscription.create!(
        user: user,
        title: form_data[:title],
        search_term: form_data[:term],
        cpv_industry_ids: form_data[:cpvs].join(','),
        countries: filter.countries(:data),
        sectors: filter.sectors(:data),
        types: filter.types(:data),
        values: filter.values(:data),
        confirmed_at: Time.zone.now
      )
    end
end
